{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.customConfig.wanderer;
in {
  imports = [./package.nix];

  options.customConfig.wanderer = {
    enable = mkEnableOption "wanderer service";
    secretsPath = mkOption {
      type = types.path;
      description = ''
        Path to secret file which contains the public facing url and meili search master key:
          ```
          ORIGIN=https://<domain>
          MEILI_MASTER_KEY=<secret-key>
          POCKETBASE_ENCRYPTION_KEY=<secret-key>
          ```
      '';
    };
    backendPort = mkOption {
      type = types.port;
      default = 8090;
      description = "Backend port for wanderer";
    };
    frontendPort = mkOption {
      type = types.port;
      default = 3000;
      description = "Frontend port for wanderer (cant be changed for now)";
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

    services.meilisearch = {
      enable = true;
      listenPort = cfg.meiliSearchPort;
      masterKeyEnvironmentFile = cfg.secretsPath;
    };
    systemd.services = {
      wanderer-db = {
        description = "Wanderer backend service";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStart = "${lib.getExe pkgs.wanderer-db} serve --http=0.0.0.0:${toString cfg.backendPort} --dir=/var/lib/wanderer-db/pb_data";
          DynamicUser = true;
          StateDirectory = ["wanderer-db" "wanderer-db/pb_data"];
          WorkingDirectory = "/var/lib/wanderer-db/pb_data";
          EnvironmentFile = cfg.secretsPath;
          Environment = "MEILI_URL=http://127.0.0.1:${toString cfg.meiliSearchPort}";

          ExecStartPre = "${lib.getExe (pkgs.writeShellScriptBin "wanderer_add_migrations_startup" ''
            if [ ! -e /var/lib/wanderer-db/pb_data/migrations ]; then
              cp -r ${pkgs.wanderer-db}/share/* /var/lib/wanderer-db/pb_data/
              chown -R --reference=/var/lib/wanderer-db/pb_data /var/lib/wanderer-db/pb_data/*
            fi
          '')}";
        };
      };

      wanderer-web = {
        description = "Wanderer frontend service";
        after = ["network.target" "wanderer-db.service"];
        requires = ["wanderer-db.service"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          ExecStart = lib.getExe pkgs.wanderer-web;
          EnvironmentFile = cfg.secretsPath;
          Environment = [
            "MEILI_URL=http://127.0.0.1:${toString cfg.meiliSearchPort}"
            "BODY_SIZE_LIMIT=Infinity"
            "PUBLIC_POCKETBASE_URL=http://127.0.0.1:${toString cfg.backendPort}"
            "PUBLIC_DISABLE_SIGNUP=true"
            "PUBLIC_PRIVATE_INSTANCE=true" # dont allow visitors from viewing trails
            "PUBLIC_VALHALLA_URL=https://valhalla1.openstreetmap.de"
            "PUBLIC_NOMINATIM_URL=https://nominatim.openstreetmap.org"
          ];
        };
      };
    };
  };
}
