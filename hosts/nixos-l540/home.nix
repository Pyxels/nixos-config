# Hyprland monitor/workspace layout and waybar modules for this host.
_: {
  customConfig = {
    hyprland.monitors = [
      {
        name = "$default_mon";
        code = "eDP-1";
      }
    ];

    hyprland.workspaces = [
      {
        name = "";
        number = 0;
      }
      {
        name = "";
        number = 1;
        default = true;
      }
      {
        name = "";
        number = 2;
      }
      {
        name = "";
        number = 3;
      }
      {
        name = "󰈙";
        number = 4;
      }
      {
        name = "";
        number = 5;
      }
      {
        name = "";
        number = 6;
      }
      {
        name = "";
        number = 7;
      }
      {
        name = "󰎄";
        number = 8;
      }
      {
        name = "";
        number = 9;
      }
    ];

    waybar.battery = true;
  };
}
