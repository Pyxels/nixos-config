rec {
  default = dev;

  dev = {
    path = ./dev;
    description = "A basic devshell template using flake-utils";
    welcomeText = ''
      # Simple Dev Shell Template
      ## Intended usage
      Simple flake to initialize a dev shell using flake-utils and direnv.
      Run `direnv allow` to enable automatic dev shell loading.
    '';
  };
}
