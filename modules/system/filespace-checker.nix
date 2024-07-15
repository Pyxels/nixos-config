{
  config,
  host,
  pkgs,
  ...
}: let
  serviceName = "filespace-checker";
in {
  imports = [
    {age.secrets.ntfy-client.file = ../../secrets/ntfy-client.age;}
  ];

  systemd.timers.${serviceName} = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "3h";
      OnUnitActiveSec = "3h";
      Unit = "${serviceName}.service";
    };
  };

  systemd.services.${serviceName} = {
    script = ''
        set -eu

      if [[ $(${pkgs.toybox}/bin/df -P / | ${pkgs.toybox}/bin/tail -n1 | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.toybox}/bin/sed "s/%//") > 90 ]]; then
        ${pkgs.ntfy-sh}/bin/ntfy pub \
          -t 'Filesystem almost full' \
          --tags 'warning,computer' \
          -m '${host.name} filespace over 90% filled. Please take action!' \
          -c '${config.age.secrets.ntfy-client.path}' \
          servers

        echo "sent notification"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
