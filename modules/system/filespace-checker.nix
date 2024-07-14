{
  host,
  pkgs,
  ...
}: let
  serviceName = "filespace-checker";
in {
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
        ${pkgs.curl}/bin/curl \
          -H "Title: Filesystem almost full" \
          -H "Tags: warning,computer" \
          -d "${host.name} filespace over 90% filled. Please take action!" \
          https://ntfy.pyxels.me/test;

        echo "sent notification"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
