{
  config,
  lib,
  pkgs,
  ...
}: let
  domain = "pyxels.me";
  bitwardenDomain = "bitwarden.${domain}";
in {
  imports = [
    ../../modules/reboot-required
  ];
  nixpkgs.overlays = [
    (import ../../overlays/beszel.nix)
    (import ../../overlays/pocket-id.nix)
  ];

  services = {
    syncthing.enable = true;
  };

  ### Vaultwarden ###
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${bitwardenDomain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = 8000;
    };
    environmentFile = "/root/vaultwarden.env";
  };
  systemd = {
    timers."vaultwarden_backup" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
        Unit = "vaultwarden_backup.service";
      };
    };
    services."vaultwarden_backup" = {
      script = ''
        ${lib.getExe pkgs.sqlite} /var/lib/bitwarden_rs/db.sqlite3 \
          ".backup '/var/lib/syncthing/vaultwarden_backups/db-$(date '+%Y-%m-%d').sqlite3'"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };

  ### BESZEL ###
  systemd.services = {
    beszel-hub = {
      description = "Beszel Hub";
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        User = "root";
        WorkingDirectory = "/root/beszel";
        ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http '0.0.0.0:8090'";
      };
      environment = {
        USER_CREATION = "true";
        SHARE_ALL_SYSTEMS = "true";
      };
      wantedBy = ["multi-user.target"];
    };
    beszel-agent = {
      description = "Beszel Agent Service";
      after = ["network.target"];
      serviceConfig = {
        Restart = "always";
        RestartSec = "5";
        ExecStart = "${pkgs.beszel}/bin/beszel-agent";
      };
      environment = {
        LISTEN = "45876";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8LG4ijPENqiHz1kS/2+CVZXKgl4nmlY0xCJPuMLhcU";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  services.uptime-kuma = {
    enable = true;
    settings = {
      UPTIME_KUMA_HOST = "0.0.0.0";
      UPTIME_KUMA_PORT = "3001";
    };
  };

  ### POCKET-ID ###
  services.pocket-id = {
    enable = true;
    settings = {
      APP_URL = "https://id.${domain}";
      TRUST_PROXY = true;
      PORT = 15649;
      UI_CONFIG_DISABLED = true;
      EMAILS_VERIFIED = true;
    };
  };

  ### REVERSE PROXY ###
  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [80 443];

  services.caddy = {
    enable = true;
    virtualHosts = {
      ${bitwardenDomain}.extraConfig = ''
        handle /admin* {
          redir https://${bitwardenDomain}/ 301
        }
        reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}
      '';
      "id.${domain}".extraConfig = "reverse_proxy 127.0.0.1:${toString config.services.pocket-id.settings.PORT}";
      "attic.${domain}".extraConfig = "reverse_proxy http://beelink:2272";
    };
  };
}
