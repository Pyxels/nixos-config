{
  inputs,
  pkgs,
  host,
  ...
}: {
  imports = [
    inputs.nixvim-config.nixosModules.default

    ./hardware-configuration.nix
    ./networking.nix
    ./server.nix
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = ["root" "@wheel"];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };
  services.journald.extraConfig = "SystemMaxUse=100M";

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = host.name;
  networking.domain = "";
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXebXmITS8OF3CLbwVC+HFRg8b/96FiEccvAfQV/ovZ jonas@jonas-bits'' ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus''];
  system.stateVersion = "23.11";
  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # 8GB
    }
  ];
  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nixvim-config = {
    enable = true;
    aliases = ["v"];
  };
}
