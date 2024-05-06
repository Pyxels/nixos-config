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

  rust-crane = {
    path = ./rust-crane;
    description = "A rust development and build flake using crane";
    welcomeText = ''
      # Rust - Crane
      ## Intended usage
      Starting point for rust development using the crane library (https://crane.dev/).
      Run `direnv allow` to enable automatic dev shell loading.
    '';
  };

  rust-dream2nix = {
    path = ./rust-dream2nix;
    description = "A rust development and build flake using dream 2 nix";
    welcomeText = ''
      # Rust - dream2nix
      ## Intended usage
      Starting point for rust development using the dream2nix library (https://nix-community.github.io/dream2nix/).
      Run `direnv allow` to enable automatic dev shell loading.
    '';
  };
}
