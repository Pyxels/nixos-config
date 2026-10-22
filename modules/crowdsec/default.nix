{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.customConfig.crowdsec;
  stateDir = "/var/lib/crowdsec";
in {
  imports = [
    {
      age.secrets.crowdsecEnrollKey = {
        file = ./crowdsec-enroll-key.age;
        owner = "crowdsec";
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
    services = {
      crowdsec = {
        enable = true;
        autoUpdateService = true;
        extraGroups = mkIf cfg.enableCaddyLogParser ["caddy"];

        hub = {
          collections =
            ["crowdsecurity/linux"]
            ++ optional cfg.enableCaddyLogParser "crowdsecurity/caddy";
          parsers = ["crowdsecurity/whitelists"];
        };

        settings = {
          config = {
            api = {
              server = {
                listen_uri = "0.0.0.0:${toString cfg.apiServerPort}";
                # keep the credential/console paths of the previous module so
                # the existing machine, console enrollment and allowlists survive
                online_client.credentials_path = "${stateDir}/online_api_credentials.yaml";
                console_path = "${stateDir}/console.yaml";
              };
              client.credentials_path = "${stateDir}/local_api_credentials.yaml";
            };
            prometheus = {
              enabled = true;
              listen_addr = "0.0.0.0";
              listen_port = 13224;
            };
          };

          console = {
            enrollKeyFile = config.age.secrets.crowdsecEnrollKey.path;
            configuration = {
              share_manual_decisions = true;
              share_custom = true;
              share_tainted = true;
              share_context = true;
              console_management = false;
            };
          };

          acquisitions =
            [
              {
                source = "journalctl";
                journalctl_filter = ["_SYSTEMD_UNIT=sshd.service"];
                labels.type = "syslog";
              }
            ]
            ++ optional cfg.enableCaddyLogParser {
              source = "file";
              labels.type = "caddy";
              filenames = [
                "${config.services.caddy.logDir}/access.log"
                "${config.services.caddy.logDir}/access-*.log"
              ];
            };
        };
      };

      crowdsec-firewall-bouncer = {
        enable = true;
        settings.api_url = "http://127.0.0.1:${toString cfg.apiServerPort}";
      };
    };
  };
}
