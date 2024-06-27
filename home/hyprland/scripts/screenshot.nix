{pkgs, ...}:
pkgs.writeShellApplication {
  name = "screenshot";

  runtimeInputs = with pkgs; [grim slurp wl-clipboard];

  text = ''
    filename=~/Pictures/screenshots/$(date -u +"%Y-%m-%d_%H-%M-%S").png

    grim -s 2 -g "$(slurp)" "$filename"
    ${pkgs.wl-clipboard}/bin/wl-copy < "$filename"
  '';
}
