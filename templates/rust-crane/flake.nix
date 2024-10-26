{
  description = "Rust Dev and Build Flake using Crane";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        lib,
        system,
        pkgs,
        ...
      }: let
        # TODO change app name
        projectName = "TODO";

        git-hooks = import ./git-hooks.nix {
          inherit lib inputs pkgs system;
        };

        buildInputs = with pkgs; [
          cargo
          clippy
          rustfmt
        ];

        craneLib = inputs.crane.mkLib pkgs;
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        cargoArtifacts = craneLib.buildDepsOnly {inherit src;};

        bin = craneLib.buildPackage {inherit src cargoArtifacts;};
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = projectName;
          tag = "latest";
          # for debugging purposes, can be removed
          contents = with pkgs; [busybox dockerTools.binSh];
          config.Cmd = ["${bin}/bin/${projectName}"];
        };
      in {
        devShells = {
          # For `nix develop` / direnv
          default = pkgs.mkShell {
            packages = with pkgs;
              [
                bacon
                cargo-audit
                rust-analyzer
              ]
              ++ buildInputs;

            inherit (git-hooks.default) shellHook;
          };

          ci = pkgs.mkShell {
            inherit buildInputs;
          };
        };

        checks = {
          # Build the crate as part of `nix flake check` for convenience
          inherit bin;

          clippy = craneLib.cargoClippy {
            inherit src cargoArtifacts;
            cargoClippyExtraArgs = "--all-targets -- --deny warnings";
          };

          fmt = craneLib.cargoFmt {
            inherit src;
          };

          nextest = craneLib.cargoNextest {
            inherit src cargoArtifacts;
          };

          # Audit dependencies
          audit = craneLib.cargoAudit {
            inherit (inputs) advisory-db;
            inherit src;
          };
        };

        packages = {
          inherit bin dockerImage;
          default = bin;
        };
      };
    };
}
