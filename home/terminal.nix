{
  inputs,
  pkgs,
  lib,
  name,
  ...
}: {
  imports = [
    inputs.nixvim-config.homeModules.default
    ./zellij
    ./bash.nix
    ./git.nix
    ./oh-my-posh.nix
    ./run_local_nixpkgs.nix
  ];

  nixvim-config = {
    enable = true;
    aliases = ["v" "vim"];
  };

  programs = {
    fzf = {
      enable = true;
      enableBashIntegration = true;
      fileWidgetCommand = "${lib.getExe pkgs.fd} --type f --hidden --exclude .git";
      fileWidgetOptions = ["--preview '${lib.getExe pkgs.bat} --color=always {}'"];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global = {
          hide_env_diff = true;
          warn_timeout = "1m";
        };
      };
    };

    atuin.enable = true;
    atuin.flags = ["--disable-up-arrow"];
  };

  home.packages = with pkgs; [
    # system
    killall
    upower

    # utilities & tools
    wl-clipboard
    btop
    ripgrep
    parallel
    bat
    fd
    eza
    less
    feh
    gh # github cli
    nh # nix helper
    inputs.attic.packages.${system}.attic-client # binary cache
  ];

  home = {
    sessionPath = [
      "/home/${name}/.cargo/bin"
    ];
    sessionVariables = {
      DIRENV_LOG_FORMAT = ''\033[2mdirenv: %s\033[0m'';
    };
  };
}
