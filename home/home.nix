{ inputs, config, pkgs, lib, host, name, configPath, ... }:

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
    ./zellij
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
    gcc # needed for nvim treesitter etc

    # utilities & tools
    jq
    jmtpfs
    btop
    ripgrep
    bat
    fd
    eza
    less
    libqalculate
    feh
    mpv
    pamixer
    termdown
    gh # github cli
    vopono # vpn tunnels

    # user apps
    kickoff
    zathura
    discord
    jellyfin-media-player

    # nix
    nvd
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];

  home.sessionPath = [
    "/home/${name}/.local/share/nvim/mason/bin"
    "${configPath}/home/scripts"
    "/home/${name}/.cargo/bin"
  ];

  home.file.".config/nvim".source = inputs.nvim-config;
  xdg.configFile.kickoff = {
    target = "kickoff/config.toml";
    source = ./kickoff.toml;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
