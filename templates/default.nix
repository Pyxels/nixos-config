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

  rust = {
    path = ./rust;
    description = "A rust development and build flake using crane";
    welcomeText = ''
      # Simple Dev Shell Template
      ## Intended usage
      Starting point for rust development using the crane library (https://crane.dev/).
      Run `direnv allow` to enable automatic dev shell loading.
    '';
  };
}
