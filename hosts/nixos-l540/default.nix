_: {
  imports = [
    ./hardware.nix
    ../../profiles/desktop.nix
  ];

  home-manager.users.jonas.imports = [./home.nix];

  hardware.bluetooth.powerOnBoot = false;

  system.stateVersion = "22.11"; # dont change
}
