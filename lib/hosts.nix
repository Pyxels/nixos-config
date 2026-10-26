# Every directory in hosts/ with a default.nix is a NixOS host. The same module
# list feeds both nixosConfigurations and the colmena hive, so they cannot drift.
{inputs}: let
  inherit (inputs.nixpkgs) lib;

  hostNames = lib.attrNames (lib.filterAttrs
    (name: type: type == "directory" && lib.pathExists ../hosts/${name}/default.nix)
    (builtins.readDir ../hosts));

  specialArgs = {inherit inputs;};

  hostModules = name: [
    inputs.agenix.nixosModules.default
    ../modules/nixos
    ../hosts/${name}
    {networking.hostName = lib.mkDefault name;}
  ];

  nixosConfigurations = lib.genAttrs hostNames (name:
    lib.nixosSystem {
      # colmena passes the node `name`, its deployment options default to it
      specialArgs = specialArgs // {inherit name;};
      modules = hostModules name ++ [inputs.colmena.nixosModules.deploymentOptions];
    });

  # hosts tagged by profiles/server.nix
  deployable = lib.filter (name: lib.elem "server" nixosConfigurations.${name}.config.deployment.tags) hostNames;
in {
  inherit nixosConfigurations;

  colmenaHive = inputs.colmena.lib.makeHive ({
      meta = {
        nixpkgs = import inputs.nixpkgs {localSystem = "x86_64-linux";};
        inherit specialArgs;
      };
    }
    // lib.genAttrs deployable (name: {imports = hostModules name;}));
}
