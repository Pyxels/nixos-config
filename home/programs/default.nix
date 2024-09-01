{
  lib,
  pkgs,
  ...
}: {
  programs = {
    alacritty.enable = true;
    alacritty.settings = import ./alacritty.nix;

    firefox = import ./firefox.nix;
  };

  services.syncthing.enable = true;

  home.packages = with pkgs; [
    mpv
    kickoff
    zathura

    discord
    jellyfin-media-player

    obsidian
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "obsidian"
    ];

  xdg.configFile.kickoff = {
    target = "kickoff/config.toml";
    source = ./kickoff.toml;
  };
}
