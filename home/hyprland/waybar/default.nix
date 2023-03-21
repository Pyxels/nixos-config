{ inputs, system, hostname, ... }: {
  programs.waybar = {
    enable = true;
    package = inputs.hyprland.packages.${system}.waybar-hyprland;
    style = ./style.css;
    settings = import ./config.nix { inherit hostname; };
  };
}
