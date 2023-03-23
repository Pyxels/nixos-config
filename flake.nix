{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    nvim-config = {
      url = "github:pyxels/nvim-config";
      flake = false;
    };

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
    hyprpaper.url = "github:hyprwm/hyprpaper";

    kickoff.url = "github:pyxels/kickoff";
    kickoff.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
    let
      name = "jonas";
      system = "x86_64-linux";
      configPath = "/home/${name}/.dotfiles";

      mkNixosSystem = hostname: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs system name hostname; }; # Pass flake inputs to our config
        modules = [
          agenix.nixosModules.default
          hyprland.nixosModules.default
          ./nixos/${hostname}/configuration.nix
        ];
      };

      mkHomeManagerConfig = name: hostname: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = { inherit inputs system hostname name configPath; }; # Pass flake inputs to our config
        modules = [
          ./home/home.nix
        ];
      };
    in
    {
      nixosConfigurations = {
        vetus = mkNixosSystem "vetus";
        nixos-l540 = mkNixosSystem "nixos-l540";
      };

      homeConfigurations = {
        "${name}@vetus" = mkHomeManagerConfig name "vetus";
        "${name}@nixos-l540" = mkHomeManagerConfig name "nixos-l540";
      };
    };
}
