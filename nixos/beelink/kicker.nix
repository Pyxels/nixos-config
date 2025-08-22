{
  inputs,
  lib,
  host,
  ...
}: let
  port = "36831";
  kicker-app = inputs.kicker-app.packages.${host.system};
in {
  services.caddy.virtualHosts = {
    "kicker.{$DOMAIN}".extraConfig = ''
      reverse_proxy localhost:${port}

      @html {
          path / /index.html
      }
      header @html Cache-Control "no-store"

      @assets {
          path /assets/*
          path_regexp static \.(js|css|woff2?|png|jpe?g|gif|svg|webp)$
      }
      header @assets Cache-Control "public, max-age=31536000, immutable"
    '';
  };

  systemd.services = {
    kicker-pocketbase = {
      description = "Kicker backend pocketbase";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = ''
          ${lib.getExe kicker-app.default} \
            --http=0.0.0.0:${port} \
            --dir=/var/lib/kicker-app/pb_data
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
