{
  inputs,
  pkgs,
  config,
  host,
  ...
}: let
  domain = "pyxels.me";
  atticDomain = "attic.${domain}";
in {
  imports = [
    inputs.attic.nixosModules.atticd
    inputs.nixvim-config.nixosModules.default

    ./hardware-configuration.nix
    ./networking.nix

    {
      age.secrets = {
        attic-config.file = ../../secrets/attic-config.age;
      };
    }
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

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
      size = 8 * 1024; # 16GB
    }
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  nixvim-config = {
    enable = true;
    aliases = ["v"];
  };

  ### ATTIC ###
  services.atticd = {
    enable = true;

    # Replace with absolute path to your credentials file
    credentialsFile = config.age.secrets.attic-config.path;

    settings = {
      listen = "[::]:8080";
      require-proof-of-possession = false;
      api-endpoint = "https://${atticDomain}/";
      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };
      garbage-collection.default-retention-period = "6 months";
    };
  };

  ### REVERSE PROXY ###
  networking.firewall.allowedTCPPorts = [80 443];
  networking.firewall.allowedUDPPorts = [80 443];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    clientMaxBodySize = "500m";

    virtualHosts.${atticDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${domain}";
  };
}
