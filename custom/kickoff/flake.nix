{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    kickoff = {
      url = "github:j0ru/kickoff";
      flake = false;
    };
  };

  outputs = { self, flake-utils, naersk, nixpkgs, kickoff }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };

        naersk' = pkgs.callPackage naersk { };

      in
      rec {
        # required libraries
        libPath = with pkgs; lib.makeLibraryPath [
          wayland
          libxkbcommon
        ];

        # For `nix build` & `nix run`:
        defaultPackage = naersk'.buildPackage {
          src = kickoff;
          nativeBuildInputs = with pkgs; [ makeWrapper fontconfig pkg-config ];
          postInstall = ''
            wrapProgram "$out/bin/kickoff" --prefix LD_LIBRARY_PATH : "${libPath}"
          '';
        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rustc cargo ];
        };
      }
    );
}
