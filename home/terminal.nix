{ inputs, pkgs, name, configPath, ... }:
{

  imports = [
    ./zellij
  ];

  programs = {
    git = import ./git.nix;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    fzf.enable = true;
    fzf.enableBashIntegration = true;
    bash = import ./bash.nix name;
    starship = import ./starship.nix;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # system
    killall
    upower
    gcc # needed for nvim treesitter etc

    # utilities & tools
    wl-clipboard
    btop
    ripgrep
    bat
    fd
    eza
    less
    feh
    gh # github cli
    inputs.nh.packages.${system}.default # nix helper

    # user apps
  ] ++ import ./scripts { inherit pkgs configPath; };

  home.sessionPath = [
    "/home/${name}/.local/share/nvim/mason/bin"
    "/home/${name}/.cargo/bin"
  ];

  home.file.".config/nvim".source = inputs.nvim-config;
}
