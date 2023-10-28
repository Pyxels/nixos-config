{ pkgs, ... }:

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

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };
  environment.systemPackages = [ pkgs.podman-compose ];
}

