_: {
  name = "vetus";
  system = "x86_64-linux";
  modules = [
    ../home/theming.nix
    ../home/hyprland
    ../home/programs
    ../home/terminal.nix

    {
      customConfig.hyprland.monitors = [
        {
          name = "$left_mon";
          code = "DVI-D-1";
        }
        {
          name = "$center_mon";
          code = "DP-2";
          position = "1920x0";
          scale = "1.5";
        }
        {
          name = "$right_mon";
          code = "DP-1";
          position = "4480x0";
        }
      ];

      customConfig.hyprland.workspaces = [
        {
          name = "";
          number = 3;
          monitor = "$left_mon";
          default = true;
        }
        {
          name = "";
          number = 1;
          monitor = "$center_mon";
          default = true;
        }
        {
          name = "";
          number = 5;
          monitor = "$center_mon";
        }
        {
          name = "";
          number = 7;
          monitor = "$center_mon";
        }
        {
          name = "";
          number = 0;
          monitor = "$center_mon";
        }
        {
          name = "";
          number = 2;
          monitor = "$right_mon";
          default = true;
        }
        {
          name = "󰈙";
          number = 4;
          monitor = "$right_mon";
        }
        {
          name = "";
          number = 6;
          monitor = "$right_mon";
        }
        {
          name = "󰎄";
          number = 8;
          monitor = "$right_mon";
        }
        {
          name = "";
          number = 9;
          monitor = "$right_mon";
        }
      ];
    }
  ];
}
