{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.customConfig.wanderer;
in {
  options.customConfig.wanderer = {
    enable = mkEnableOption "wanderer service";
    secretsPath = mkOption {
      type = types.path;
      description = ''
        Path to secret file which contains the public facing url and meili search master key:
          ```
          WANDERER_DOMAIN=<domain>
          ORIGIN=https://<domain>
          MEILI_MASTER_KEY=<secret-key>
          ```
        The file should be accessible by the user `caddy` if ran with reverse proxy on.
      '';
    };
    enableReverseProxy = mkOption {
      type = types.bool;
      default = true;
      description = "Enable reverse proxy";
    };
    oauth2ProxySecretsPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Set to enable access to reverse proxy only with OIDC. The file should contain the config as env vars in the format `OAUTH2_PROXY_<key>=<value>`.";
    };
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/wanderer";
      description = "Wanderer state directory (without trailing /)";
    };
    backendPort = mkOption {
      type = types.port;
      default = 8090;
      description = "Backend port for wanderer";
    };
    frontendPort = mkOption {
      type = types.port;
      default = 3000;
      description = "Frontend port for wanderer";
    };
    meiliSearchPort = mkOption {
      type = types.port;
      default = 7700;
      description = "Port for meilisearch";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretsPath != null;
        message = "Secrets path needs to be set";
      }
    ];

    services.caddy = mkIf cfg.enableReverseProxy {
      enable = true;
      virtualHosts."{$WANDERER_DOMAIN}" = {
        extraConfig = ''
          handle /oauth2/* {
            reverse_proxy 127.0.0.1:4180 {
              header_up X-Real-IP {http.request.header.CF-Connecting-IP}
              header_up X-Forwarded-Uri {uri}
            }
          }

          handle {
            forward_auth 127.0.0.1:4180 {
              uri /oauth2/auth

              header_up X-Real-IP {http.request.header.CF-Connecting-IP}

              @error status 401
              handle_response @error {
                redir * /oauth2/sign_in?rd={scheme}://{host}{uri}
              }
            }

            reverse_proxy http://127.0.0.1:${toString cfg.frontendPort}
          }
        '';
      };
      environmentFile = cfg.secretsPath;
    };
    networking.firewall = mkIf cfg.enableReverseProxy {
      allowedTCPPorts = [80 443];
      allowedUDPPorts = [80 443];
    };

    services.oauth2-proxy = mkIf (cfg.oauth2ProxySecretsPath != null) {
      enable = true;
      provider = "oidc";
      extraConfig.reverse-proxy = true;
      keyFile = cfg.oauth2ProxySecretsPath;
    };

    system.activationScripts = {
      podman-wanderer-network = ''
        ${lib.getExe pkgs.podman} network exists wanderer-net \
          || ${lib.getExe pkgs.podman} network create wanderer-net
      '';
      wanderer-create-state-dir = "mkdir -p ${cfg.stateDir}/{data.ms,pb_data,uploads}";
    };

    virtualisation.oci-containers.containers = {
      "wanderer-search" = {
        image = "docker.io/getmeili/meilisearch:v1.11.3";
        extraOptions = ["--network=wanderer-net"];
        ports = ["${toString cfg.meiliSearchPort}:7700"];
        volumes = ["${cfg.stateDir}/data.ms:/meili_data/data.ms"];
        environmentFiles = [cfg.secretsPath];
        environment = {
          MEILI_URL = "http://wanderer-search:7700";
          MEILI_NO_ANALYTICS = "true";
        };
      };
      "wanderer-db" = {
        image = "docker.io/flomp/wanderer-db:v0.15.2";
        dependsOn = ["wanderer-search"];
        extraOptions = ["--network=wanderer-net"];
        ports = ["${toString cfg.backendPort}:8090"];
        volumes = ["${cfg.stateDir}/pb_data:/pb_data"];
        environmentFiles = [cfg.secretsPath];
        environment = {
          MEILI_URL = "http://wanderer-search:7700";
        };
      };
      "wanderer-web" = {
        image = "docker.io/flomp/wanderer-web:v0.15.2";
        dependsOn = ["wanderer-search" "wanderer-db"];
        extraOptions = ["--network=wanderer-net"];
        ports = ["${toString cfg.frontendPort}:3000"];
        volumes = ["${cfg.stateDir}/uploads:/app/uploads"];
        environmentFiles = [cfg.secretsPath];
        environment = {
          MEILI_URL = "http://wanderer-search:7700";
          BODY_SIZE_LIMIT = "Infinity";
          PUBLIC_POCKETBASE_URL = "http://wanderer-db:8090";
          PUBLIC_DISABLE_SIGNUP = "true";
          UPLOAD_FOLDER = "/app/uploads";
          UPLOAD_USER = "";
          UPLOAD_PASSWORD = "";
          PUBLIC_VALHALLA_URL = "https://valhalla1.openstreetmap.de";
          PUBLIC_NOMINATIM_URL = "https://nominatim.openstreetmap.org";
        };
      };
    };
  };
}
