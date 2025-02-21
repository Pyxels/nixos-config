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

    ../../modules/wanderer
    ../../modules/reboot-required

    {
      age.secrets = {
        wandererSecrets.file = ../../secrets/wanderer.age;
        oauth2ProxySecrets = {
          file = ../../secrets/oauth2-proxy.age;
          owner = "oauth2-proxy";
        };
        domain = {
          file = ../../secrets/beelink-private-domain.age;
          owner = "caddy";
        };
      };
    }
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

  ### WANDERER ###
  customConfig.wanderer = {
    enable = true;
    secretsPath = config.age.secrets.wandererSecrets.path;
  };

  ### AUDIOBOOKSHELF ###
  services.audiobookshelf.enable = true;

  ### JELLYFIN ###
  services.jellyfin.enable = true;
  services.jellyseerr.enable = true;

  ### REVERSE PROXY ###
  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    extraConfig.reverse-proxy = true;
    keyFile = config.age.secrets.oauth2ProxySecrets.path;
  };
  services.caddy = let
    mkOauth2Proxy = port: ''
      handle /oauth2/* {
        reverse_proxy 127.0.0.1:4180 {
          header_up X-Real-IP {http.request.header.CF-Connecting-IP}
          header_up X-Forwarded-Uri {uri}
        }
      }

      handle {
        forward_auth 127.0.0.1:4180 {
          uri /oauth2/auth

          header_up X-Real-IP {http.request.header.CF-Connecting-IP}

          @error status 401
          handle_response @error {
            redir * /oauth2/sign_in?rd={scheme}://{host}{uri}
          }
        }

        reverse_proxy http://127.0.0.1:${port}
      }
    '';
  in {
    enable = true;
    virtualHosts = {
      "trails.{$DOMAIN}".extraConfig = mkOauth2Proxy (toString config.customConfig.wanderer.frontendPort);
      "audio.{$DOMAIN}".extraConfig = "reverse_proxy http://127.0.0.1:${toString config.services.audiobookshelf.port}";
      "media.{$DOMAIN}".extraConfig = "reverse_proxy http://127.0.0.1:8096";
      "request.{$DOMAIN}".extraConfig = "reverse_proxy http://127.0.0.1:${toString config.services.jellyseerr.port}";
    };
    environmentFile = config.age.secrets.domain.path;
  };
}
