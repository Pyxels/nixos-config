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
    url = mkOption {
      type = types.nullOr types.str;
      example = "wanderer.example.com";
      description = "URL where wanderer will be accessible";
      default = null;
    };
    urlSecretPath = mkOption {
      type = types.nullOr types.path;
      description = "Path to secret file which contains the public facing url in the format: ORIGIN=https://<domain>";
      default = null;
    };
    meiliSecretPath = mkOption {
      type = types.path;
      description = "Path to secret file which contains the meilisearch master key in the format: MEILI_MASTER_KEY=<secretkey>";
    };
    enableNginx = mkOption {
      type = types.bool;
      default = true;
      description = "Enable nginx reverse proxy with ACME";
    };
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/wanderer";
      description = "Wanderer state directory";
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
    warnings =
      if (cfg.url != null && cfg.urlSecretPath != null)
      then ["You have set both url and secret url path. Behaviour not defined."]
      else [];
    assertions = [
      {
        assertion = cfg.url != null || cfg.urlSecretPath != null;
        message = "Either url or urlSecretPath should be set.";
      }
      {
        assertion = (cfg.enableNginx && cfg.url != null) || !cfg.enableNginx;
        message = "Sadly, you currently need to set url to use nix managed nginx reverse proxy.";
      }
    ];

    services.nginx = mkIf cfg.enableNginx {
      enable = true;
      virtualHosts."${cfg.url}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString cfg.frontendPort}";
        };
      };
    };

    system.activationScripts = {
      podman-wanderer-network = ''
        ${lib.getExe pkgs.podman} network exists wanderer-net \
          || ${lib.getExe pkgs.podman} network create wanderer-net
      '';
      wanderer-create-state-dir = "mkdir -p /var/lib/wanderer/{data.ms,pb_data,uploads}";
    };

    virtualisation.oci-containers.containers = {
      "wanderer-search" = {
        image = "docker.io/getmeili/meilisearch:v1.11.3";
        extraOptions = ["--network=wanderer-net"];
        ports = ["${toString cfg.meiliSearchPort}:7700"];
        volumes = ["${cfg.stateDir}/data.ms:/meili_data/data.ms"];
        environmentFiles = [cfg.meiliSecretPath];
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
        environmentFiles = [cfg.meiliSecretPath];
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
        environmentFiles =
          [cfg.meiliSecretPath]
          ++ (
            if cfg.urlSecretPath != null
            then [cfg.urlSecretPath]
            else []
          );
        environment =
          {
            MEILI_URL = "http://wanderer-search:7700";
            BODY_SIZE_LIMIT = "Infinity";
            PUBLIC_POCKETBASE_URL = "http://wanderer-db:8090";
            PUBLIC_DISABLE_SIGNUP = "true";
            UPLOAD_FOLDER = "/app/uploads";
            UPLOAD_USER = "";
            UPLOAD_PASSWORD = "";
            PUBLIC_VALHALLA_URL = "https://valhalla1.openstreetmap.de";
            PUBLIC_NOMINATIM_URL = "https://nominatim.openstreetmap.org";
          }
          // (
            if cfg.url != null
            then {
              ORIGIN = "https://${cfg.url}";
            }
            else {}
          );
      };
    };
  };
}
