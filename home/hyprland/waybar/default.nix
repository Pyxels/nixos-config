{
  config,
  lib,
  ...
}: let
  cfg = config.customConfig.waybar;
in {
  options.customConfig.waybar = {
    battery = lib.mkEnableOption "the battery module";
    gpuTempPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "hwmon input for the GPU temperature module, module is hidden when null.";
    };
    cpuTempPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "hwmon input for the temperature module, waybar auto-detects when null.";
    };
  };

  config.programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = import ./config.nix {inherit cfg;};
  };
}
