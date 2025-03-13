{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.customConfig.pinchflat;
in {
  options.customConfig.pinchflat = {
    enable = mkEnableOption "pinchflat service";
    configDir = mkOption {
      type = types.str;
      default = "/var/lib/pinchflat/config";
      description = "Pinchflat config directory";
    };
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/pinchflat/data";
      description = "Pinchflat data directory";
    };
    port = mkOption {
      type = types.port;
      default = 8945;
      description = "Port for pinchflat";
    };
  };

  config = mkIf cfg.enable {
    system.activationScripts = {
      pinchflat-create-dirs = "mkdir -p ${cfg.dataDir} ${cfg.configDir}";
    };

    virtualisation.oci-containers.containers."pinchflat" = {
      image = "ghcr.io/kieraneglin/pinchflat:v2025.3.6";
      ports = ["${toString cfg.port}:8945"];
      volumes = ["${cfg.configDir}:/config" "${cfg.dataDir}:/downloads"];
      environment = {
        TZ = "Europe/Berlin";
      };
    };
  };
}
