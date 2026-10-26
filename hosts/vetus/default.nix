{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ../../profiles/desktop.nix
  ];

  home-manager.users.jonas.imports = [./home.nix];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  environment.systemPackages = [pkgs.docker-compose];
  users.users.jonas.extraGroups = ["docker"];

  system.stateVersion = "22.11"; # dont change
}
