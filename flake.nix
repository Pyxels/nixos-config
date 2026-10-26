{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:pyxels/nixvim-config";
      inputs.git-hooks.follows = "git-hooks";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    inherit (nixpkgs) lib;
    hosts = import ./lib/hosts.nix {inherit inputs;};

    forAllSystems = f:
      lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"]
      (system: f nixpkgs.legacyPackages.${system});

    gitHooks = pkgs:
      import ./git-hooks.nix {
        inherit inputs pkgs;
        inherit (pkgs.stdenv.hostPlatform) system;
      };
  in {
    inherit (hosts) nixosConfigurations colmenaHive;

    homeConfigurations."jonas@jonas-bits" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {inherit inputs;};
      modules = [./hosts/jonas-bits/home.nix];
    };

    templates = import ./templates;

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs =
          (gitHooks pkgs).enabledPackages
          ++ (with pkgs; [
            nix-output-monitor
            inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena
            just
            fzf
            nvd
          ]);

        shellHook = ''
          ${(gitHooks pkgs).shellHook}

          just
        '';
      };
    });

    checks = forAllSystems (pkgs: {
      git-hooks = gitHooks pkgs;
    });
  };
}
