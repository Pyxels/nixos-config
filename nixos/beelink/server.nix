{
  config,
  pkgs,
  ...
}: {
  imports = [
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

  services = {
    ### AUDIOBOOKSHELF ###
    audiobookshelf.enable = true;

    ### JELLYFIN ###
    jellyfin.enable = true;
    jellyseerr.enable = true;

    ### REVERSE PROXY ###
    oauth2-proxy = {
      enable = true;
      provider = "oidc";
      extraConfig.reverse-proxy = true;
      keyFile = config.age.secrets.oauth2ProxySecrets.path;
    };
    caddy = let
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
  };
}
