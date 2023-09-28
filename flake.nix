{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nvim-config = {
      url = "github:pyxels/nvim-config";
      flake = false;
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
  };

  outputs = { nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
    let
      name = "jonas";
      hosts = [{ name = "vetus"; system = "x86_64-linux"; } { name = "nixos-l540"; system = "x86_64-linux"; }];
      configPath = "/home/${name}/.dotfiles";

      mkNixosSystems = hosts:
        builtins.listToAttrs (map
          (host: {
            name = host.name;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs name host; };
              modules = [
                agenix.nixosModules.default
                ./nixos/${host.name}/configuration.nix
              ];
            };
          })
          hosts);

      mkHomeConfigs = name: hosts:
        builtins.listToAttrs (map
          (host: {
            name = "${name}@${host.name}";
            value = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${host.system}; # Home-manager requires 'pkgs' instance
              extraSpecialArgs = { inherit inputs host name configPath; };
              modules = [
                ./home/home.nix
              ];
            };
          })
          hosts);
    in
    {
      nixosConfigurations = mkNixosSystems hosts;

      homeConfigurations = mkHomeConfigs name hosts;
    };
}
