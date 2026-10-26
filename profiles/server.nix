# Headless machines deployed with colmena (`just deploy`).
{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./base.nix
    inputs.nixvim-config.nixosModules.default
  ];

  # colmena hive membership, see lib/hosts.nix
  deployment.tags = ["server"];

  boot.tmp.cleanOnBoot = true;

  services.openssh.settings.PasswordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = (import ../secrets/keys.nix).admins;

  nixvim-config = {
    enable = true;
    aliases = ["v"];
  };

  customConfig.reboot-required.enable = true;

  ### BESZEL ###
  systemd.services.beszel-agent = {
    description = "Beszel Agent Service";
    after = ["network.target"];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
      ExecStart = "${pkgs.beszel}/bin/beszel-agent";
    };
    environment = {
      LISTEN = "45876";
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8LG4ijPENqiHz1kS/2+CVZXKgl4nmlY0xCJPuMLhcU";
    };
    wantedBy = ["multi-user.target"];
  };

  ### CADDY ###
  # file logging, also read by crowdsec's caddy parser
  services.caddy.globalConfig = ''
    log stdout_logger {
     output file ${config.services.caddy.logDir}/access.log {
        roll_size 10MB
        roll_keep 5
        roll_keep_for 14d
        mode 0640
      }
      level INFO
    }
  '';
}
