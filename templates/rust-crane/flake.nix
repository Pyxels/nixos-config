{
  description = "Rust Dev and Build Flake using Crane";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    crane,
    pre-commit-hooks,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        # TODO: replace with crate name
        project-name = "mycrate";

        pkgs = nixpkgs.legacyPackages.${system};

        pre-commit-check.${system} = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            rustfmt.enable = true;
            clippy.enable = true;
            clippy.settings.denyWarnings = true;
          };
        };

        buildInputs = with pkgs; [
          cargo
          clippy
          rustfmt
        ];

        craneLib = crane.lib.${system};
        src = craneLib.cleanCargoSource (craneLib.path ./.);
        cargoArtifacts = craneLib.buildDepsOnly {inherit src;};

        bin = craneLib.buildPackage {inherit src cargoArtifacts;};
        dockerImage = pkgs.dockerTools.buildImage {
          name = project-name;
          tag = "latest";
          config = {
            Cmd = ["${bin}/bin/${project-name}"];
          };
        };
      in {
        devShells = {
          # For `nix develop` / direnv
          default = pkgs.mkShell {
            packages = with pkgs;
              [
                cargo-watch
                cargo-audit
                rust-analyzer
              ]
              ++ buildInputs;

            shellHook =
              pre-commit-check.${system}.shellHook;
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
            inherit src;
            advisory-db = inputs.advisory-db;
          };
        };

        packages = {
          inherit bin dockerImage;
          default = bin;
        };
      }
    );
}
