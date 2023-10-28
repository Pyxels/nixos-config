{ pkgs, name, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared-configuration.nix
    ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  environment.systemPackages = [ pkgs.docker-compose ];
  users.users.${name}.extraGroups = [ "docker" ];
}

