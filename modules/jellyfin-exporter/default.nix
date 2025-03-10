{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.customConfig.jellyfin-exporter;
in {
  imports = [./package.nix];
  options.customConfig.jellyfin-exporter = {
    enable = mkEnableOption "jellyfin metrics exporter";
    secrets = mkOption {
      type = types.path;
      description = ''
        Path to file containing the following secrets:
          ```
          JELLYFIN_BASEURL=https://<url>;
          JELLYFIN_APIKEY=<key>;
          ```
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.jellyfin-exporter = {
      description = "Jellyfin Metrics Exporter";
      after = ["network.target"];
      serviceConfig = {
        Restart = "always";
        RestartSec = "5";
        ExecStart = lib.getExe pkgs.jellyfin-exporter;
      };
      serviceConfig.EnvironmentFile = [cfg.secrets];
      wantedBy = ["multi-user.target"];
    };
  };
}
