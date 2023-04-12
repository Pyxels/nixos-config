{ inputs, config, pkgs, system, lib, hostname, name, configPath, ... }:

{
  home.username = name;
  home.homeDirectory = "/home/${name}";

  # dont change
  home.stateVersion = "22.11";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  qt.enable = true;
  qt.style.name = "adwaita-dark";
  gtk.enable = true;
  gtk.theme.name = "Adwaita-dark";

  home.pointerCursor = {
    name = "phinger-cursors";
    package = pkgs.phinger-cursors;
    gtk.enable = true;
  };

  imports = [
    ./hyprland
  ];

  services = {
    dunst = import ./dunst.nix;
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    git = import ./git.nix;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    fzf.enable = true;
    fzf.enableBashIntegration = true;
    alacritty.enable = true;
    alacritty.settings = import ./alacritty.nix;
    bash = import ./bash.nix name;
    starship = import ./starship.nix;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    firefox = import ./firefox.nix;
  };

  home.packages = with pkgs; [
    # system
    killall
    upower
    libnotify
    socat

    # utilities & tools
    jq
    jmtpfs
    btop
    ripgrep
    bat
    fd
    exa
    less
    libqalculate
    feh
    mpv
    pamixer
    termdown

    # programming shit
    gcc
    rustup

    # user apps
    zathura
    discord
    qbittorrent
    kodi-wayland

    # nix
    nvd

    inputs.kickoff.defaultPackage.${system}
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];

  home.sessionPath = [
    "/home/${name}/.local/share/nvim/mason/bin"
    "${configPath}/home/scripts"
  ];

  home.file.".config/nvim".source = inputs.nvim-config;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
