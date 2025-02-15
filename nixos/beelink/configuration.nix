{
  inputs,
  pkgs,
  host,
  config,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixvim-config.nixosModules.default

    ./hardware-configuration.nix
    ./disko-config.nix
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

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings = {
      trusted-users = ["root" "@wheel"];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  boot.tmp.cleanOnBoot = true;
  networking.hostName = host.name;
  services = {
    openssh.enable = true;
    openssh.settings.PasswordAuthentication = false;
    tailscale.enable = true;
    syncthing.enable = true;
  };
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXebXmITS8OF3CLbwVC+HFRg8b/96FiEccvAfQV/ovZ jonas@jonas-bits'' ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus''];
  users.users.jonas = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
    openssh.authorizedKeys.keys = config.users.users.root.openssh.authorizedKeys.keys;
  };

  programs.bash.interactiveShellInit = let
    RED = "\\033[31m";
    YELLOW = "\\033[33m";
    BLUE = "\\033[34m";
    RESET = "\\033[0m";
  in ''
    if [ $( (readlink `readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules,systemd}`; \
             readlink /run/booted-system/{initrd,kernel,kernel-modules,systemd}) | sort -u | wc -l ) -ne 4 ]; then
      echo -e "\n${RED}Looks like the booted version does not match the current version kernel/initrd/systemd. Please reboot!${RESET}"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/initrd)" "$(readlink `readlink /nix/var/nix/profiles/system/initrd`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/kernel)" "$(readlink `readlink /nix/var/nix/profiles/system/kernel`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/kernel-modules)" "$(readlink `readlink /nix/var/nix/profiles/system/kernel-modules`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/systemd)" "$(readlink `readlink /nix/var/nix/profiles/system/systemd`)"
    fi
  '';

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nixvim-config = {
    enable = true;
    aliases = ["v"];
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

  ### BESZEL ###
  systemd.services = {
    beszel-agent = {
      description = "Beszel Agent Service";
      after = ["network.target"];
      serviceConfig = {
        Restart = "always";
        RestartSec = "5";
        ExecStart = "${pkgs.beszel}/bin/beszel-agent";
      };
      environment = {
        PORT = "45876";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8LG4ijPENqiHz1kS/2+CVZXKgl4nmlY0xCJPuMLhcU";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [80 443];
    allowedUDPPorts = [80 443 config.services.tailscale.port];
    trustedInterfaces = ["tailscale0"];
  };
}
