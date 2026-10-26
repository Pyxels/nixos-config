# Workstations: hyprland session, audio, and home-manager for the main user.
{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./base.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
  };
  systemd.enableEmergencyMode = false;

  networking.networkmanager.enable = true;

  services = {
    mullvad-vpn.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
  };

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
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.roboto-mono
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord-unwrapped"
      "discord"
    ];

  programs.hyprland.enable = true;
  security.pam.services.swaylock = {};
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #########################################
  # Users
  #########################################
  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "dialout"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    users.jonas.imports = [
      ../home
      ../home/desktop.nix
    ];
  };
}
