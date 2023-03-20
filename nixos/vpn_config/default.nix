{ config, ... }:
{
  age.secrets = {
    vpn-credentials.file = ../../secrets/vpn-credentials.age;
    vpn-config.file = ../../secrets/vpn-config.age;
  };

  services.openvpn.servers = {
    standard_home = {
      autoStart = true;
      config = ''
        config ${config.age.secrets.vpn-config.path}
        auth-user-pass ${config.age.secrets.vpn-credentials.path}
      '';
    };
  };
}

