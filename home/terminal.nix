{
  inputs,
  pkgs,
  name,
  host,
  ...
}: {
  imports = [
    ./zellij
    ./bash.nix
    ./git.nix
    ./starship.nix
    ./run_local_nixpkgs.nix
  ];

  programs = {
    fzf.enable = true;
    fzf.enableBashIntegration = true;

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
    nixvim-config
  ];

  nixpkgs.overlays = [
    (_: _: {nixvim-config = inputs.nixvim-config.packages.${host.system}.default;})
  ];

  home = {
    sessionPath = [
      "/home/${name}/.cargo/bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
      DIRENV_LOG_FORMAT = ''\033[2mdirenv: %s\033[0m'';
    };
  };
}
