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
          ORIGIN=https://<domain>
          MEILI_MASTER_KEY=<secret-key>
          ```
      '';
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

    system.activationScripts = {
      wanderer-create-state-dir = "mkdir -p ${cfg.stateDir}/{data.ms,pb_data,uploads}";
    };

    systemd.services."podman-wanderer-network" = {
      path = [pkgs.podman];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "${lib.getExe pkgs.podman} network rm -f wanderer-net";
      };
      script = ''
        podman network inspect wanderer-net \
          || podman network create wanderer-net --driver=bridge
      '';
      partOf = ["podman-compose-test-root.target"];
      wantedBy = ["multi-user.target"];
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
        image = "docker.io/flomp/wanderer-db:v0.16.5";
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
        image = "docker.io/flomp/wanderer-web:v0.16.5";
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
