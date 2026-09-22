{
  description = "Basic Dev Shell";
  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";

  outputs = {nixpkgs, ...}: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ] (system: function nixpkgs.legacyPackages.${system} system);
  in {
    devShells = forAllSystems (pkgs: _system: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          bashInteractive
        ];
      };
    });
  };
}
