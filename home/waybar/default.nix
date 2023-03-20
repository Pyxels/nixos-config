{ inputs, system, ...}: {
  programs.waybar = {
    enable = true;
    package = inputs.hyprland.packages.${system}.waybar-hyprland;
    style = ./style.css;
    settings = import ./config.nix;
  };
}
