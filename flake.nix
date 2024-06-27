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

    nixvim-config = {
      url = "github:pyxels/nixvim-config";
      inputs = {
        flake-parts.follows = "flake-parts";
        pre-commit-hooks.follows = "git-hooks";
      };
    };

    hyprland.url = "github:hyprwm/Hyprland";
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

  outputs = {nixpkgs, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      flake = let
        name = "jonas";
        configPath = "/home/${name}/.dotfiles";
        hosts = ["vetus" "nixos-l540"];
        homes = hosts ++ ["jonas-bits"];

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
                extraSpecialArgs = {inherit inputs name configPath host;};
                modules = [./home/home.nix] ++ host.modules;
              };
            })
            hosts);
      in {
        nixosConfigurations = mkNixosSystems hosts;
        homeConfigurations = mkHomeConfigs name homes;

        templates = import ./templates;
      };

      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        git-hooks = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            flake-checker.enable = true;
            nil.enable = true;
            deadnix = {
              enable = true;
              settings.exclude = ["./nixos/vetus/hardware-configuration.nix" "./nixos/nixos-l540/hardware-configuration.nix" "./templates/rust-crane/flake.nix"];
            };
            statix = {
              enable = true;
              settings.ignore = ["**/*hardware-configuration.nix"];
            };

            shellcheck.enable = true;
            actionlint.enable = true;
            commitizen.enable = true;
            check-merge-conflicts.enable = true;
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          inherit (git-hooks) shellHook;
          buildInputs = git-hooks.enabledPackages;
        };

        checks = {
          inherit git-hooks;
        };
      };
    };
}
