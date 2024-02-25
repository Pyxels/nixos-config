{...}: {
  name = "nixos-l540";
  system = "x86_64-linux";
  modules = [
    ../home/theming.nix
    ../home/hyprland
    ../home/programs
    ../home/terminal.nix

    {
      customConfig.hyprland.monitors = [
        {
          name = "$default_mon";
          code = "eDP-1";
        }
      ];

      customConfig.hyprland.workspaces = [
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
    }
  ];
}
