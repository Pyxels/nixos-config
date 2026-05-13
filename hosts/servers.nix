{
  inputs,
  nixpkgs,
  name,
  servers,
}: let
  hostInfos = map (hostName: import ./${hostName}.nix {} // {inherit hostName;}) servers;

  mkNode = host: {
    name = host.hostName;
    value = {
      deployment = {
        targetHost = host.name;
        targetUser = "root";
        buildOnTarget = host.system == "aarch64-linux";
      };
      nixpkgs.hostPlatform = host.system;
      imports = [
        inputs.agenix.nixosModules.default
        ../nixos/${host.hostName}/configuration.nix
      ];
    };
  };

  nodeSpecialArgs = builtins.listToAttrs (map (host: {
      name = host.hostName;
      value = {inherit host;};
    })
    hostInfos);
in
  {
    meta = {
      nixpkgs = import nixpkgs {system = "x86_64-linux";};
      specialArgs = {inherit inputs name;};
      inherit nodeSpecialArgs;
    };
  }
  // builtins.listToAttrs (map mkNode hostInfos)
