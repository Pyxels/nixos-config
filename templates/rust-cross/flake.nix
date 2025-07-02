{
  description = "Rust cross compile to arm musl";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # see https://crane.dev/examples/cross-musl.html
  # see https://mediocregopher.com/posts/x-compiling-rust-with-nix.gmi
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (
          p:
            p.rust-bin.stable.latest.default.override {
              targets = ["aarch64-unknown-linux-musl"];
            }
        );
      in rec {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [(import inputs.rust-overlay)];
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            cargo
          ];
        };

        packages.default = craneLib.buildPackage rec {
          src = craneLib.cleanCargoSource ./.;

          strictDeps = true;
          doCheck = false;

          TARGET_CC = "${pkgs.pkgsCross.aarch64-multiplatform-musl.stdenv.cc}/bin/${pkgs.pkgsCross.aarch64-multiplatform-musl.stdenv.cc.targetPrefix}cc";
          CARGO_BUILD_TARGET = "aarch64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static -C linker=${TARGET_CC}";
        };

        checks = {
          package = packages.default;
        };
      };
    };
}
