_: {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./services.nix
    ../../profiles/server.nix
  ];

  # aarch64, cross building from x86_64 is slow
  deployment.buildOnTarget = true;

  services.journald.settings.Journal.SystemMaxUse = "100M";

  zramSwap.enable = true;
  networking.domain = "";
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # 8GB
    }
  ];

  system.stateVersion = "23.11";
}
