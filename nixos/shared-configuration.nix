{
  inputs,
  pkgs,
  name,
  host,
  ...
}: {
  imports = [];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
  };
  systemd.enableEmergencyMode = false;

  networking.networkmanager.enable = true;
  networking.hostName = host.name;

  services = {
    openssh.enable = true;
    mullvad-vpn.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
  services.tailscale.enable = true;

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "de_DE.UTF-8";
  console = {
    keyMap = "de";
  };

  #########################################
  # Global packages
  #########################################
  environment.systemPackages = with pkgs; [
    vim
    git

    inputs.agenix.packages.${host.system}.default
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];

  programs.hyprland.enable = true;
  security.pam.services.swaylock = {};
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #########################################
  # Users
  #########################################
  users.users.${name} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
    ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  # dont change
  system.stateVersion = "22.11"; # Did you read the comment?
}
