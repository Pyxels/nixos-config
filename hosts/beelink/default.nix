{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko

    ./hardware.nix
    ./disko.nix
    ./services.nix
    ./home-assistant.nix
    ../../profiles/server.nix
  ];

  system.stateVersion = "25.05";
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  fileSystems."/mnt/big_hdd" = {
    device = "/dev/disk/by-uuid/bca72139-dbd7-45b7-87ce-7ad48403a5af";
    fsType = "ext4";
  };
  systemd.enableEmergencyMode = false;

  nix.gc.options = "--delete-older-than 30d";

  services = {
    syncthing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };
  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = ["--all"];
    };
  };
  environment.shellAliases = {
    dc = "docker compose";
  };
}
