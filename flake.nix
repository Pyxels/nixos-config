{
  description = "My first NixOS Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";

    kickoff.url = "path:custom/kickoff";
  };

  outputs = { nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
    let
      hostname = "nixos-l540";
      name = "jonas";
      system = "x86_64-linux";
      configPath = "/home/jonas/.dotfiles";
    in
    {
      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system; }; # Pass flake inputs to our config
          modules = [
            agenix.nixosModules.default
            hyprland.nixosModules.default
            ./nixos/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "${name}@${hostname}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
          extraSpecialArgs = { inherit inputs system name configPath; }; # Pass flake inputs to our config
          modules = [
            ./home/home.nix
          ];
        };
      };
    };
}
