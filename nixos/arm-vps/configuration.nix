{
  lib,
  inputs,
  pkgs,
  config,
  host,
  ...
}: let
  domain = "pyxels.me";
  atticDomain = "attic.${domain}";
  bitwardenDomain = "bitwarden.${domain}";
in {
  imports = [
    inputs.nixvim-config.nixosModules.default

    ./hardware-configuration.nix
    ./networking.nix

    {
      age.secrets = {
        attic-config.file = ../../secrets/attic-config.age;
      };
    }
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = ["root" "@wheel"];
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

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
      size = 8 * 1024; # 8GB
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

  services.syncthing.enable = true;

  ### ATTIC ###
  services.atticd = {
    enable = true;

    environmentFile = config.age.secrets.attic-config.path;
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

  ### MONITORING ###
  services.prometheus = {
    port = 3020;
    enable = true;

    exporters = {
      node = {
        port = 3021;
        enabledCollectors = ["systemd"];
        enable = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3030;
      };

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/tmp/loki";
        storage.filesystem = {
          chunks_directory = "/tmp/loki/chunks";
          rules_directory = "/tmp/loki/rules";
        };
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      query_range.results_cache.cache.embedded_cache = {
        enabled = true;
        max_size_mb = 100;
      };

      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      analytics.reporting_enabled = false;
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        protocol = "http";
        http_port = 3010;
        http_addr = "127.0.0.1";
        rootUrl = "https://grafana.${domain}/";
      };
      analytics.reporting_enable = false;
    };

    provision.datasources.settings = {
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
        }
      ];
    };
  };

  ### Vaultwarden ###
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://${bitwardenDomain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = 8000;
    };
    environmentFile = "/root/vaultwarden.env";
  };
  systemd = {
    timers."vaultwarden_backup" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
        Unit = "vaultwarden_backup.service";
      };
    };
    services."vaultwarden_backup" = {
      script = ''
        ${lib.getExe pkgs.sqlite} /var/lib/bitwarden_rs/db.sqlite3 \
          ".backup '/var/lib/syncthing/vaultwarden_backups/db-$(date '+%Y-%m-%d').sqlite3'"
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
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

    upstreams = {
      "attic".servers."127.0.0.1:8080" = {};
      "grafana".servers."127.0.0.1:${toString config.services.grafana.settings.server.http_port}" = {};
      "prometheus".servers."127.0.0.1:${toString config.services.prometheus.port}" = {};
      "loki".servers."127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}" = {};
      "promtail".servers."127.0.0.1:${toString config.services.promtail.configuration.server.http_listen_port}" = {};
      "bitwarden".servers."127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}" = {};
    };

    virtualHosts.${atticDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://attic";
      };
    };

    virtualHosts."grafana.${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://grafana";
        proxyWebsockets = true;
      };
    };

    virtualHosts.${bitwardenDomain} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://bitwarden";
        proxyWebsockets = true;
      };
      locations."/admin" = {
        return = "301 https://${bitwardenDomain}/";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@${domain}";
  };
}
