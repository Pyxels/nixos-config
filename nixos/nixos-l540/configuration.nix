{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../shared-configuration.nix
  ];

  hardware.bluetooth.powerOnBoot = false;
}
