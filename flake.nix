{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "home-manager";
      };
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:pyxels/nixvim-config";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };

    crowdsec = {
      url = "git+https://codeberg.org/kampka/nix-flake-crowdsec.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kicker-app.url = "github:pyxels/kicker-app/refs/tags/0.0.7";
  };

  outputs = {nixpkgs, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      flake = let
        name = "jonas";
        configPath = "/home/${name}/.dotfiles";
        hosts = [
          "vetus"
          "nixos-l540"
          "minimal-iso"
          "beelink"
        ];
        homes = hosts ++ ["jonas-bits"];
        servers = ["arm-vps"];

        mkNixosSystems = hosts:
          builtins.listToAttrs (
            map (
              hostName: let
                host = import ./hosts/${hostName}.nix {};
              in {
                name = hostName;
                value = nixpkgs.lib.nixosSystem {
                  specialArgs = {inherit inputs name host;};
                  modules = [
                    inputs.agenix.nixosModules.default
                    ./nixos/${hostName}/configuration.nix
                  ];
                };
              }
            )
            hosts
          );

        mkHomeConfigs = name: hosts:
          builtins.listToAttrs (
            map (
              hostName: let
                host = import ./hosts/${hostName}.nix {};
              in {
                name = "${name}@${hostName}";
                value = inputs.home-manager.lib.homeManagerConfiguration {
                  pkgs = nixpkgs.legacyPackages.${host.system}; # Home-manager requires 'pkgs' instance
                  extraSpecialArgs = {
                    inherit
                      inputs
                      name
                      configPath
                      host
                      nixpkgs
                      ;
                  };
                  modules = [./home/home.nix] ++ host.modules;
                };
              }
            )
            hosts
          );
      in {
        nixosConfigurations = mkNixosSystems (hosts ++ servers);
        homeConfigurations = mkHomeConfigs name homes;

        templates = import ./templates;

        colmenaHive = inputs.colmena.lib.makeHive (import ./hosts/servers.nix {
          inherit inputs nixpkgs name;
          servers = ["arm-vps" "beelink"];
        });
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        git-hooks = import ./git-hooks.nix {inherit inputs system;};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs =
            git-hooks.enabledPackages
            ++ (with pkgs; [
              nix-output-monitor
              inputs.colmena.packages.${system}.colmena
              just
            ]);

          shellHook = ''
            ${git-hooks.shellHook}

            just
          '';
        };

        checks = {
          inherit git-hooks;
        };
      };
    };
}
