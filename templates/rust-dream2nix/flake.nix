{
  description = "Rust - dream2nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    dream2nix,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    bin = dream2nix.lib.evalModules {
      packageSets.nixpkgs = pkgs;
      modules = [
        ./default.nix
      ];
    };
  in {
    devShells = {
      default = pkgs.mkShell {
        packages = with pkgs; [
          cargo-watch
          cargo-audit
          rust-analyzer
        ];
      };
    };

    packages.${system} = {
      default = bin;

      docker = pkgs.dockerTools.buildImage {
        name = bin.name;
        tag = bin.version;
        config.Cmd = ["${bin}/bin/${bin.name}"];
      };
    };
  };
}
