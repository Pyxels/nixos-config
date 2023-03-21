{ inputs, config, system, pkgs, hostname, configPath, ... }: {
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = import ./config.nix { inherit hostname configPath; };
  };

  home.packages = with pkgs; [
    libsForQt5.polkit-kde-agent
    hyprpaper
    wl-clipboard
    grim
    slurp
    swaylock
  ];

  nixpkgs.overlays = [
    (_: _: { hyprpaper = inputs.hyprpaper.packages.${system}.default; })
  ];
  home.file.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  home.file.".config/hypr/img/background.png".source = ./background.png;
  home.file.".config/hypr/img/lockscreen.png".source = ./lockscreen.png;
}
