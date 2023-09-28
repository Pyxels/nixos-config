{ inputs, system, hostname, ... }: {
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = import ./config.nix { inherit hostname; };
  };
}
