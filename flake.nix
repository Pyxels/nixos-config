{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
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

    kickoff.url = "github:pyxels/kickoff";
    kickoff.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
    let
      name = "jonas";
      hosts = [ "vetus" "nixos-l540" ];
      system = "x86_64-linux";
      configPath = "/home/${name}/.dotfiles";

      mkNixosSystems = hostnames:
        builtins.listToAttrs (map
          (hostname: {
            name = hostname;
            value = nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs system name hostname; }; # Pass flake inputs to our config
              modules = [
                agenix.nixosModules.default
                ./nixos/${hostname}/configuration.nix
              ];
            };
          })
          hostnames);

      mkHomeConfigs = name: hostnames:
        builtins.listToAttrs (map
          (hostname: {
            name = "${name}@${hostname}";
            value = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
              extraSpecialArgs = { inherit inputs system hostname name configPath; }; # Pass flake inputs to our config
              modules = [
                ./home/home.nix
              ];
            };
          })
          hostnames);
    in
    {
      nixosConfigurations = mkNixosSystems hosts;

      homeConfigurations = mkHomeConfigs name hosts;
    };
}
