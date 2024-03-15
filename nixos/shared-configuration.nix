{ inputs, pkgs, name, host, ... }:

{
  imports =
    [
      ./vpn_config
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
  };

  networking.networkmanager.enable = true;
  networking.hostName = host.name;

  services.openssh.enable = true;
  services.mullvad-vpn.enable = true;

  hardware.bluetooth.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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
    (nerdfonts.override { fonts = [ "RobotoMono" ]; })
  ];

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${host.system}.hyprland;
  security.pam.services.swaylock = { };


  #########################################
  # Users
  #########################################
  users.users.${name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };

  # dont change
  system.stateVersion = "22.11"; # Did you read the comment?

}

