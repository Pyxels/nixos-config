{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
        home-manager.follows = "home-manager";
      };
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim-config = {
      url = "github:pyxels/nixvim-config";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper = {
      url = "github:hyprwm/hyprpaper";
      inputs = {
        hyprlang.follows = "hyprland/hyprlang";
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
      };
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    self,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      flake = let
        name = "jonas";
        configPath = "/home/${name}/.dotfiles";
        hosts = ["vetus" "nixos-l540" "minimal-iso"];
        homes = hosts ++ ["jonas-bits"];
        servers = ["arm-vps"];

        mkNixosSystems = hosts:
          builtins.listToAttrs (map
            (hostName: let
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
            })
            hosts);

        mkHomeConfigs = name: hosts:
          builtins.listToAttrs (map
            (hostName: let
              host = import ./hosts/${hostName}.nix {};
            in {
              name = "${name}@${hostName}";
              value = inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.${host.system}; # Home-manager requires 'pkgs' instance
                extraSpecialArgs = {inherit inputs name configPath host nixpkgs;};
                modules = [./home/home.nix] ++ host.modules;
              };
            })
            hosts);
      in {
        nixosConfigurations = mkNixosSystems (hosts ++ servers);
        homeConfigurations = mkHomeConfigs name homes;

        templates = import ./templates;

        deploy = import ./hosts/servers.nix {inherit inputs self;};
      };

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        git-hooks = import ./git-hooks.nix {inherit inputs system;};
      in {
        devShells.default = pkgs.mkShell {
          inherit (git-hooks) shellHook;
          buildInputs =
            git-hooks.enabledPackages
            ++ [pkgs.deploy-rs];
        };

        checks = {
          inherit git-hooks;
        };
      };
    };
}
