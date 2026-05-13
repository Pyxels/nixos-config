{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.customConfig.crowdsec;
  atticWhitelistParser = pkgs.writeText "attic-whitelist.yaml" ''
    name: custom/attic-whitelist
    description: "Whitelist Attic cache vhost"
    whitelist:
      reason: "attic.pyxels.me cache traffic"
      expression:
        - "evt.Meta.target_fqdn != nil && (evt.Meta.target_fqdn == 'attic.pyxels.me' || evt.Meta.target_fqdn startsWith 'attic.pyxels.me:')"
  '';
in {
  # disabled newer crowdsec module in nixpkgs in favor of https://codeberg.org/kampka/nix-flake-crowdsec
  # due to lazyness to migrate
  disabledModules = [
    "services/security/crowdsec.nix"
    "services/security/crowdsec-firewall-bouncer.nix"
  ];

  imports = [
    inputs.crowdsec.nixosModules.crowdsec
    inputs.crowdsec.nixosModules.crowdsec-firewall-bouncer

    {
      age.secrets = {
        crowdsecEnrollKey = {
          file = ./crowdsec-enroll-key.age;
          owner = "crowdsec";
        };
        crowdsecFirewallKey = {
          file = ./crowdsec-firewall-key.age;
          owner = "crowdsec";
        };
      };
    }
  ];

  options.customConfig.crowdsec = {
    enable = mkEnableOption "crowdsec";
    apiServerPort = mkOption {
      type = types.port;
      default = 13223;
      description = "Port for the local api server";
    };
    enableCaddyLogParser = mkOption {
      type = types.bool;
      default = true;
      description = "Enable caddy log parsing";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: _prev: let
        sys = final.stdenv.hostPlatform.system;
      in {
        crowdsec = inputs.crowdsec.packages.${sys}.crowdsec;
        crowdsec-firewall-bouncer = inputs.crowdsec.packages.${sys}.crowdsec-firewall-bouncer;
      })
    ];
    services = {
      crowdsec = {
        enable = true;
        enrollKeyFile = config.age.secrets.crowdsecEnrollKey.path;
        settings = {
          api.server.listen_uri = "0.0.0.0:${toString cfg.apiServerPort}";
          prometheus = {
            enabled = true;
            listen_addr = "0.0.0.0";
            listen_port = 13224;
          };
        };

        acquisitions = mkIf cfg.enableCaddyLogParser [
          {
            labels.type = "caddy";
            filenames = [
              "${config.services.caddy.logDir}/access.log"
              "${config.services.caddy.logDir}/access-*.log"
            ];
          }
        ];
      };
      crowdsec-firewall-bouncer = {
        enable = true;
        settings = {
          api_key = "\${API_KEY}";
          api_url = "http://localhost:${toString cfg.apiServerPort}";
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/crowdsec/config/parsers 0750 crowdsec crowdsec - -"
      "d /var/lib/crowdsec/config/parsers/s02-enrich 0750 crowdsec crowdsec - -"
      "L+ /var/lib/crowdsec/config/parsers/s02-enrich/attic-whitelist.yaml - - - - ${atticWhitelistParser}"
    ];

    systemd.services = {
      crowdsec.serviceConfig.ExecStartPre = [
        (lib.getExe (
          pkgs.writeShellScriptBin "install-configurations" ''
            if ! cscli collections list | grep -q "caddy"; then
                cscli collections install crowdsecurity/caddy
            fi
            if ! cscli collections list | grep -q "linux"; then
                cscli collections install crowdsecurity/linux
            fi
            if ! cscli parsers list | grep -q "whitelists"; then
                cscli parsers install crowdsecurity/whitelists
            fi
          ''
        ))
        (lib.getExe (
          pkgs.writeShellScriptBin "register-bouncer" ''
            if ! cscli bouncers list | grep -q "firewall"; then
                cscli bouncers add "firewall" --key "$(cat ${config.age.secrets.crowdsecFirewallKey.path} | cut -d= -f2)"
            fi
          ''
        ))
      ];

      crowdsec-firewall-bouncer.serviceConfig.EnvironmentFile =
        config.age.secrets.crowdsecFirewallKey.path;
    };

    # ensure crowdsec can access logs
    users.users.crowdsec.extraGroups = mkIf cfg.enableCaddyLogParser ["caddy"];
  };
}
