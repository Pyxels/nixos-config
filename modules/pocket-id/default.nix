{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.customConfig.pocket-id;
in {
  options.customConfig.pocket-id = {
    enable = mkEnableOption "pocket-id service";
    url = mkOption {
      type = types.str;
      example = "pocket.example.com";
      description = "Url where pocket-id will be accessible.";
    };
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/pocket-id";
      description = "Pocket-id state directory.";
    };
    port = mkOption {
      type = types.port;
      default = 8100;
      description = "Port for pocket-id.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.url}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            proxy_busy_buffers_size   512k;
            proxy_buffers   4 512k;
            proxy_buffer_size   256k;
          '';
        };
      };
    };

    users.users."pocket-id" = {
      uid = 2001;
      isSystemUser = true;
      createHome = false;
      group = "pocket-id";
    };

    users.groups."pocket-id" = {
      gid = 2001;
    };

    virtualisation.oci-containers.containers."pocket-id" = {
      image = "ghcr.io/pocket-id/pocket-id:v0.32.0";
      ports = ["127.0.0.1:${toString cfg.port}:8100"];
      volumes = ["${cfg.stateDir}:/app/backend/data"];
      environment = {
        PUBLIC_APP_URL = "https://${cfg.url}";
        TRUST_PROXY = "true";
        PUID = "${toString config.users.users."pocket-id".uid}";
        PGID = "${toString config.users.groups."pocket-id".gid}";
        CADDY_PORT = "8100";
      };
    };
  };
}
