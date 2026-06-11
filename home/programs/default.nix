{
  lib,
  pkgs,
  config,
  ...
}: {
  programs = {
    alacritty.enable = true;
    alacritty.settings = import ./alacritty.nix;

    firefox = {
      enable = true;
      profiles.Profile0 = {
        id = 0;
        name = "default";
        path = "r9f1s9wy.default";
        isDefault = true;
        settings = {
          "privacy.webrtc.legacyGlobalIndicator" = false;
        };
      };
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };

  services.syncthing.enable = true;

  home.packages = with pkgs; [
    mpv
    kickoff
    zathura

    discord
    jellyfin-media-player
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
    ];

  xdg.configFile.kickoff = {
    target = "kickoff/config.toml";
    source = ./kickoff.toml;
  };
}
