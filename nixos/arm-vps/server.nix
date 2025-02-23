{
  config,
  lib,
  pkgs,
  ...
}: let
  domain = "pyxels.me";
  bitwardenDomain = "bitwarden.${domain}";
in {
  imports = [
    ../../modules/pocket-id
    ../../modules/reboot-required
  ];

  services = {
    syncthing.enable = true;

    ### MONITORING ###
    prometheus = {
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

    loki = {
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

    promtail = {
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

    grafana = {
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

  ### BESZEL ###
  systemd.services = {
    beszel-hub = {
      description = "Beszel Hub";
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        User = "root";
        WorkingDirectory = "/root/beszel";
        ExecStart = "${pkgs.beszel}/bin/beszel-hub serve --http '0.0.0.0:8090'";
      };
      environment = {
        USER_CREATION = "true";
      };
      wantedBy = ["multi-user.target"];
    };
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

  ### POCKET-ID ###
  customConfig.pocket-id = {
    enable = true;
    url = "id.${domain}";
  };
}
