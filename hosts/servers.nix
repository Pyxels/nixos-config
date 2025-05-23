{
  inputs,
  self,
}: {
  nodes = {
    arm-vps = let
      system = "aarch64-linux";
    in {
      hostname = "arm-vps";
      remoteBuild = true;
      sshUser = "root";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.arm-vps;
      };
    };
    beelink = let
      system = "x86_64-linux";
    in {
      hostname = "beelink";
      sshUser = "root";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.beelink;
      };
    };
  };
}
