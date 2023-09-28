{ inputs, lib, config, pkgs, name, host, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../shared-configuration.nix
    ];

  networking.firewall.allowedTCPPorts = [ 6969 9090 ];
}

