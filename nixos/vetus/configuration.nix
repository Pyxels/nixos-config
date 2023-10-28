{ pkgs, name, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared-configuration.nix
    ];

  virtualisation = {
    podman = {
      enable = true;
      dockerSocket.enable = true;
    };
  };
  environment.systemPackages = [ pkgs.docker-compose ];
  users.users.${name}.extraGroups = [ "podman" ];
}

