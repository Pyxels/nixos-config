{pkgs, ...}:
pkgs.writeShellScriptBin "screenshot" ''

  filename=~/Pictures/screenshots/$(date -u +"%Y-%m-%d_%H-%M-%S").png

  ${pkgs.grim}/bin/grim -s 2 -g "$(${pkgs.slurp}/bin/slurp)" "$filename"
  ${pkgs.wl-clipboard}/bin/wl-copy < "$filename"

''
