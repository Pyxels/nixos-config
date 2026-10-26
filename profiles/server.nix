# Headless machines deployed with colmena (`just deploy`).
{
  inputs,
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
