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
    
    # Pinning to commit due to build breakage, see https://github.com/hyprwm/Hyprland/issues/1842
    hyprland.url = "github:hyprwm/Hyprland/37ced6aca4ad8f18f8e205e3cdb6de9c8964d4b6";
    hyprpaper.url = "github:hyprwm/hyprpaper";

    kickoff.url = "path:custom/kickoff";
  };

  outputs = { nixpkgs, home-manager, hyprland, agenix, ... }@inputs:
    let
      hostname = "vetus";
      name = "jonas";
      system = "x86_64-linux";
      configPath = "/home/${name}/.dotfiles";
    in
    {
      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs system name hostname; }; # Pass flake inputs to our config
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
          extraSpecialArgs = { inherit inputs system hostname name configPath; }; # Pass flake inputs to our config
          modules = [
            ./home/home.nix
          ];
        };
      };
    };
}
