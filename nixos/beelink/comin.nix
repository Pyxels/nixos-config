{inputs, ...}: {
  imports = [inputs.comin.nixosModules.comin];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/pyxels/nixos-config.git";
        branches.main.name = "master";
      }
    ];
    exporter = {
      port = 4243;
    };
  };
}
