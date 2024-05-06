{
  lib,
  dream2nix,
  ...
}: let
  fs = lib.fileset;
  rustSrc = fs.toSource {
    root = ./.;
    fileset = fs.unions [./Cargo.lock ./Cargo.toml ./src];
  };
in {
  imports = [
    dream2nix.modules.dream2nix.rust-cargo-lock
    dream2nix.modules.dream2nix.rust-crane
  ];

  mkDerivation = {
    src = rustSrc;
  };

  deps = {nixpkgs, ...}: {
    inherit (nixpkgs) stdenv;
  };

  name = "bartib";
  version = "1.1.0";
}
