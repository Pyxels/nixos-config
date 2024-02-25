{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    nixvim-config = {
      url = "github:pyxels/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
  };

  outputs = {
    nixpkgs,
    home-manager,
    agenix,
    ...
  } @ inputs: let
    name = "jonas";
    configPath = "/home/${name}/.dotfiles";
    hosts = ["vetus" "nixos-l540" "jonas-bits"];

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
  in {
    nixosConfigurations = mkNixosSystems hosts;

    homeConfigurations = mkHomeConfigs name hosts;
  };
}
