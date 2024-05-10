{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
      inputs.nixpkgs.follows = "nixpkgs";
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

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    agenix,
    ...
  } @ inputs: let
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
              agenix.nixosModules.default
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
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.${host.system}; # Home-manager requires 'pkgs' instance
            extraSpecialArgs = {inherit inputs name configPath host;};
            modules = [./home/home.nix] ++ host.modules;
          };
        })
        hosts);

    git-hooks = inputs.pre-commit-hooks.lib.x86_64-linux.run {
      src = ./.;
      hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        flake-checker.enable = true;
        nil.enable = true;
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
    nixosConfigurations = mkNixosSystems hosts;
    homeConfigurations = mkHomeConfigs name homes;

    templates = import ./templates;

    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      inherit (git-hooks) shellHook;
      buildInputs = git-hooks.enabledPackages;
    };
  };
}
