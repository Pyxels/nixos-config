{ inputs, config, pkgs, host, configPath, ... }: {
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./waybar
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = import ./config.nix { inherit pkgs host configPath; };
  };

  home.packages = with pkgs; [
    libsForQt5.polkit-kde-agent
    hyprpaper
    wl-clipboard
    swaylock
  ];

  nixpkgs.overlays = [
    (_: _: { hyprpaper = inputs.hyprpaper.packages.${host.system}.default; })
  ];
  home.file.".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
  home.file.".config/hypr/img/background.png".source = ./background.png;
  home.file.".config/hypr/img/lockscreen.png".source = ./lockscreen.png;

  services = {
    dunst = import ./dunst.nix;
  };

  home.packages = with pkgs; [
    libnotify
    pamixer
  ];
}
