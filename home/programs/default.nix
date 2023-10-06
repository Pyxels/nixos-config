{ lib, pkgs, ... }:
{
  programs = {
    alacritty.enable = true;
    alacritty.settings = import ./alacritty.nix;

    firefox = import ./firefox.nix;
  };

  home.packages = with pkgs; [
    mpv
    kickoff
    zathura

    discord
    jellyfin-media-player
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];

  xdg.configFile.kickoff = {
    target = "kickoff/config.toml";
    source = ./kickoff.toml;
  };
}
