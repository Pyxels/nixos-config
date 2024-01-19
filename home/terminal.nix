{ inputs, pkgs, name, configPath, ... }:
{

  imports = [
    ./zellij
  ];

  programs = {
    git = import ./git.nix;

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
    inputs.nixvim-config.packages.${system}.default # my nvim instance

    # user apps
  ] ++ import ./scripts { inherit pkgs configPath; };

  home.sessionPath = [
    "/home/${name}/.cargo/bin"
  ];
}
