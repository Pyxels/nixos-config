{host}: {
  mainBar = {
    layer = "top";
    position = "bottom";

    modules-left = [
      "hyprland/workspaces"
      "custom/right-arrow-dark"
      "custom/right-arrow-light"
      "hyprland/window"
      "custom/right-arrow-dark"
    ];
    modules-center = [
      "custom/left-arrow-dark"
      "clock#1"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "clock#2"
      "custom/right-arrow-dark"
      "custom/right-arrow-light"
      "clock#3"
      "custom/right-arrow-dark"
    ];
    modules-right =
      [
        "custom/left-arrow-dark"
        "pulseaudio"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "memory"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "cpu"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "temperature"
      ]
      ++ (
        if host.name == "vetus"
        then [
          "custom/gpu-temp"
        ]
        else []
      )
      ++ [
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "bluetooth"
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "custom/vpn"
      ]
      ++ (
        if host.name == "nixos-l540"
        then [
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "battery"
        ]
        else []
      )
      ++ [
        "custom/left-arrow-light"
        "custom/left-arrow-dark"
        "tray"
      ];

    "custom/left-arrow-dark" = {
      format = "";
      tooltip = false;
    };
    "custom/left-arrow-light" = {
      format = "";
      tooltip = false;
    };
    "custom/right-arrow-dark" = {
      format = "";
      tooltip = false;
    };
    "custom/right-arrow-light" = {
      format = "";
      tooltip = false;
    };

    "hyprland/workspaces" = {
      format = "{name}";
    };

    "clock#1" = {
      format = "{:%a}";
      tooltip = false;
    };
    "clock#2" = {
      format = "{:%H:%M}";
      tooltip = false;
    };
    "clock#3" = {
      format = "{:%m-%d}";
      tooltip = false;
    };

    "custom/vpn" = {
      exec = "printf \"%s\" $(mullvad status | head -n1 | sed \"s/^Connected.*/󰌾/\" | sed \"s/^Disconnected.*//\")";
      interval = 5;
    };
    "custom/gpu-temp" = {
      exec = "echo $(($(cat /sys/class/hwmon/hwmon2/temp1_input) / 1000 ))";
      format = "GPU: {}°C";
      interval = 5;
    };

    pulseaudio = {
      format = "{icon} {volume:2}%";
      format-bluetooth = "{icon}  {volume}%";
      format-muted = "MUTE";
      format-icons = {
        headphones = "";
        default = [
          ""
          ""
        ];
      };
      scroll-step = 5;
      on-click = "pamixer -t";
      on-click-right = "pavucontrol";
    };
    memory = {
      interval = 5;
      format = "Mem {}%";
    };
    cpu = {
      interval = 5;
      format = "CPU {usage:2}%";
    };
    battery = {
      states = {
        good = 95;
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-icons = [
        ""
        ""
        ""
        ""
        ""
      ];
    };
    temperature =
      {
        critical-threshold = 80;
        format-critical = "{temperatureC}°C {icon}";
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" "󰈸"];
      }
      // (
        if host.name == "vetus"
        then {
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
        }
        else {}
      );
    bluetooth = {
      format = " {status}";
      format-connected = " {num_connections}";
      tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
      tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
      tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
    };
    disk = {
      interval = 5;
      format = "Disk {percentage_used:2}%";
      path = "/";
    };
    tray = {
      icon-size = 20;
    };
  };
}
