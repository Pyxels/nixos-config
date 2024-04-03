{
  inputs,
  pkgs,
  name,
  configPath,
  ...
}: {
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
    atuin.enable = true;
    atuin.flags = ["--disable-up-arrow"];
  };

  home.packages = with pkgs;
    [
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
      inputs.nixvim-config.packages.${system}.default # my nvim instance
    ]
    ++ import ./scripts {inherit pkgs configPath;};

  home = {
    sessionPath = [
      "/home/${name}/.cargo/bin"
    ];
    sessionVariables.EDITOR = "nvim";
  };
}
