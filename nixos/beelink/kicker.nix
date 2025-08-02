{
  inputs,
  lib,
  host,
  ...
}: let
  port = "36831";
  kickerPkgs = inputs.kicker-app.packages.${host.system};
in {
  services.caddy.virtualHosts = {
    "kicker.{$DOMAIN}".extraConfig = "reverse_proxy localhost:${port}";
  };

  systemd.services = {
    kicker-pocketbase = {
      description = "Kicker backend pocketbase";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = ''
          ${lib.getExe kickerPkgs.pocketbase} \
            serve \
            --http=0.0.0.0:${port} \
            --dir=/var/lib/kicker-app/pb_data \
            --migrationsDir=${kickerPkgs.backend-data}/pb_migrations \
            --publicDir=${kickerPkgs.frontend-dist}/dist
        '';
        DynamicUser = true;
        StateDirectory = [
          "kicker-app"
          "kicker-app/pb_data"
        ];
      };
    };
  };
}
