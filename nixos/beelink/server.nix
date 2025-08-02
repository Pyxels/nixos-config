{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/wanderer
    ../../modules/reboot-required
    ../../modules/jellyfin-exporter

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
        sonarr = {
          file = ../../secrets/beelink-sonarr-key.age;
          group = "media";
          mode = "770";
        };
        radarr = {
          file = ../../secrets/beelink-radarr-key.age;
          group = "media";
          mode = "770";
        };
        prowlarr = {
          file = ../../secrets/beelink-prowlarr-key.age;
          group = "media";
          mode = "770";
        };
        jellyfin-exporter.file = ../../secrets/beelink-jellyfin-exporter.age;
        attic-config.file = ../../secrets/attic-config.age;
      };
    }
  ];

  ### OVERRIDES ###
  nixpkgs.overlays = [
    (import ../../overlays/beszel.nix)
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
        LISTEN = "45876";
        KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8LG4ijPENqiHz1kS/2+CVZXKgl4nmlY0xCJPuMLhcU";
      };
      wantedBy = ["multi-user.target"];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [
      80
      443
      config.services.tailscale.port
    ];
    trustedInterfaces = ["tailscale0"];
  };

  customConfig = {
    ### WANDERER ###
    wanderer = {
      enable = false;
      secretsPath = config.age.secrets.wandererSecrets.path;
    };
  };

  services = {
    ### AUDIOBOOKSHELF ###
    audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
    };

    ### JELLYFIN ###
    jellyfin.enable = true;
    jellyseerr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
  };
  customConfig.jellyfin-exporter = {
    enable = true;
    secrets = config.age.secrets.jellyfin-exporter.path;
  };

  users.groups."media".members = [
    "jonas"
    "sonarr"
    "radarr"
    "prowlarr"
    "jellyfin"
    "audiobookshelf"
  ];

  ### IMMICH ###
  system.activationScripts = {
    immich-create-media-dir = "mkdir -p ${config.services.immich.mediaLocation} && chown ${config.services.immich.user}:${config.services.immich.group} ${config.services.immich.mediaLocation}";
  };
  services = {
    immich = {
      enable = true;
      mediaLocation = "/mnt/big_hdd/photos";
      accelerationDevices = null;
      host = "0.0.0.0";
    };
  };

  ### SCRUTINY ###
  services.scrutiny = {
    enable = true;
  };

  ### Monitoring ###
  services = {
    prometheus = {
      port = 3020;
      enable = true;
      retentionTime = "90y";
      extraFlags = ["--web.enable-remote-write-receiver"];

      exporters = {
        node = {
          port = 3021;
          enabledCollectors = [
            "systemd"
            "filesystem"
          ];
          enable = true;
        };
        exportarr-sonarr = {
          port = 3022;
          enable = true;
          group = "media";
          url = "http://127.0.0.1:8989";
          apiKeyFile = config.age.secrets.sonarr.path;
          environment.ENABLE_ADDITIONAL_METRICS = "true";
        };
        exportarr-radarr = {
          port = 3023;
          enable = true;
          group = "media";
          url = "http://127.0.0.1:7878";
          apiKeyFile = config.age.secrets.radarr.path;
        };
        exportarr-prowlarr = {
          port = 3024;
          enable = true;
          group = "media";
          url = "http://127.0.0.1:9696";
          apiKeyFile = config.age.secrets.prowlarr.path;
        };
      };

      scrapeConfigs = [
        {
          job_name = "local";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
                "127.0.0.1:${toString config.services.prometheus.exporters.exportarr-sonarr.port}"
                "127.0.0.1:${toString config.services.prometheus.exporters.exportarr-radarr.port}"
                "127.0.0.1:${toString config.services.prometheus.exporters.exportarr-prowlarr.port}"
                "127.0.0.1:19091"
                "127.0.0.1:9027" # jellyfin-exporter
              ];
            }
          ];
        }
        {
          job_name = "home";
          static_configs = [
            {
              targets = [
                "127.0.0.1:${builtins.head (builtins.split ":" (builtins.head config.virtualisation.oci-containers.containers.shelly-plugs-exporter.ports))}"
              ];
            }
          ];
        }
      ];
    };

    grafana = {
      enable = true;

      settings = {
        server.http_port = 3010;
        server.http_addr = "0.0.0.0";
        analytics.reporting_enable = false;
      };

      provision.datasources.settings = {
        datasources = [
          {
            name = "Beelink-Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
        ];
      };
    };
  };
  systemd.services.grafana.serviceConfig.EnvironmentFile = config.age.secrets.domain.path;

  services.atticd = {
    enable = true;
    environmentFile = config.age.secrets.attic-config.path;
    settings = {
      listen = "[::]:2272";
      require-proof-of-possession = false;
    };
  };

  virtualisation.oci-containers.containers = {
    shelly-plugs-exporter = {
      image = "lukassoo/shelly-plus-plug-exporter:latest";
      ports = ["10009:10009"];
      volumes = ["/etc/shelly-plugs-exporter/config:/Config:ro"];
    };
  };

  ### REVERSE PROXY ###
  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    extraConfig.reverse-proxy = true;
    keyFile = config.age.secrets.oauth2ProxySecrets.path;
    httpAddress = "http://0.0.0.0:4180";
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
      "grafana.{$DOMAIN}".extraConfig = mkOauth2Proxy (
        toString config.services.grafana.settings.server.http_port
      );
      "photos.{$DOMAIN}".extraConfig = "reverse_proxy http://127.0.0.1:${toString config.services.immich.port}";
    };
    environmentFile = config.age.secrets.domain.path;
  };
}
