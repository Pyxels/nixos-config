{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.customConfig.hyprland;

  generateWorkspaces = workspaces:
    lib.lists.flatten (
      map (ws: [
        "SUPER, ${toString ws.number}, workspace, name:${ws.name}"
        "SUPER_SHIFT, ${toString ws.number}, movetoworkspacesilent, name:${ws.name}"
      ])
      workspaces
    );

  generateWorkspaceMonitorBindings = workspaces:
    map (
      ws: ''name:${ws.name}, monitor:${ws.monitor}, default:${
          if ws.default or false
          then "true"
          else "false"
        }''
    )
    workspaces;

  generateMonitors = monitors:
    builtins.listToAttrs (
      map (monitor: {
        inherit (monitor) name;
        value = monitor.code;
      })
      monitors
    );
in {
  imports = [
    ./waybar
    ./scripts
  ];

  options.customConfig.hyprland = {
    workspaces = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The name of the workspace.";
            };

            number = lib.mkOption {
              type = lib.types.int;
              description = "The workspace number.";
            };

            monitor = lib.mkOption {
              type = lib.types.str;
              description = "Identifier for the monitor this workspace is on.";
              default = "$default_mon";
            };

            default = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is the default workspace.";
            };
          };
        }
      );
      example = [
        {
          name = "Ws 1";
          number = 1;
          monitor = "$center_mon";
          default = true;
        }
      ];
      default = [];
      description = "List of workspace configurations.";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The identifier used within the configuration for this monitor.";
            };
            code = lib.mkOption {
              type = lib.types.str;
              description = "The hardware code of the monitor, used by the system to identify it.";
            };
            resolution = lib.mkOption {
              type = lib.types.str;
              default = "preferred";
              description = "The resolution setting for the monitor. Use 'preferred' for the default resolution.";
            };
            position = lib.mkOption {
              type = lib.types.str;
              default = "0x0";
              description = "The position of the monitor in the virtual display space, in the format 'XxY'.";
            };
            scale = lib.mkOption {
              type = lib.types.str;
              default = "1";
              description = "The scaling factor for the monitor.";
            };
          };
        }
      );
      example = [
        {
          name = "$left_mon";
          code = "DVI-D-1";
          resolution = "preferred";
          position = "0x0";
          scale = "1";
        }
      ];
      default = [];
      description = "List of monitor configurations.";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.monitors != [];
        message = "The 'customConfig.hyprland.monitors' option must be set and not be empty.";
      }
      {
        assertion = cfg.workspaces != [];
        message = "The 'customConfig.hyprland.workspaces' option must be set and not be empty.";
      }
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      # see https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
      package = null;
      portalPackage = null;

      settings =
        {
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          input = {
            kb_layout = "de";
            kb_variant = "nodeadkeys";

            follow_mouse = 2;
          };

          general = {
            gaps_in = 3;
            gaps_out = 10;
            border_size = 2;
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";

            layout = "master";
          };

          cursor.inactive_timeout = 5;
          cursor.enable_hyprcursor = false;

          misc = {
            mouse_move_focuses_monitor = false;
            disable_hyprland_logo = true;
          };

          decoration = {
            rounding = 5;
            inactive_opacity = 0.85;
            shadow.enabled = false;

            blur = {
              passes = 2;
              ignore_opacity = true;
            };
          };

          animations = {
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

            animation = [
              "windows,    1, 5,   myBezier"
              "windowsOut, 1, 5,   default, popin 80%"
              "border,     1, 10,  default"
              "fade,       1, 7,   default"
              "workspaces, 1, 6,   default"
            ];
          };

          windowrulev2 = [
            "bordercolor rgb(fb4934), fullscreen:1"
            "bordercolor rgb(d3869b), pinned:1"
          ];

          bind =
            [
              # Basic
              "SUPER,    Return,      exec, ${pkgs.alacritty}/bin/alacritty"
              "SUPER,    Q,           killactive,"
              "CTRL_ALT, BackSpace,   exit,"

              # Applications
              "SUPER, D, exec, ${pkgs.kickoff}/bin/kickoff"
              "SUPER, W, exec, ${pkgs.firefox}/bin/firefox"
              "SUPER, N, exec, ${pkgs.alacritty}/bin/alacritty -e ${pkgs.libqalculate}/bin/qalc"

              # Shortcuts
              "SUPER,       Period, exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -i 2"
              "SUPER_SHIFT, Period, exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -i 10"
              "SUPER,       Comma,  exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -d 2"
              "SUPER_SHIFT, Comma,  exec, ${pkgs.pamixer}/bin/pamixer --allow-boost -d 10"
              "SUPER_SHIFT, B,      exec, headset_toggle"
              "SUPER_SHIFT, L,      exec, ${pkgs.swaylock}/bin/swaylock -eFi ~/.config/hypr/img/lockscreen.png"

              # Layout
              "SUPER,       Space,  layoutmsg, swapwithmaster master"
              "SUPER_SHIFT, Space,  togglefloating,"
              "SUPER,       F,      fullscreen, 1"
              "SUPER_SHIFT, F,      fullscreen, 0"
              "SUPER,       J,      layoutmsg, cyclenext"
              "SUPER,       K,      layoutmsg, cycleprev"
              "SUPER_SHIFT, J,      layoutmsg, swapnext"
              "SUPER_SHIFT, K,      layoutmsg, swapprev"
              "SUPER_SHIFT, S,      pin"

              "SUPER_SHIFT, Left,   layoutmsg, orientationleft"
              "SUPER_SHIFT, Up,     layoutmsg, orientationtop"
              "SUPER_SHIFT, Right,  layoutmsg, orientationright"
              "SUPER_SHIFT, Down,   layoutmsg, orientationbottom"
              "SUPER,       C,      layoutmsg, orientationcenter"

              "SUPER, L, splitratio, +0.05"
              "SUPER, H, splitratio, -0.05"

              # Interactive workspace selector/creator
              "SUPER,       Y, exec, select_workspace"
              "SUPER_SHIFT, Y, exec, create_workspace"
            ]
            ++ generateWorkspaces cfg.workspaces;

          # Move/resize windows with mainMod + LMB/RMB and dragging
          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];

          ########################################################################################
          # Startup
          ########################################################################################

          exec-once = [
            "waybar"
            "hyprpaper -n"
            "polkit-kde-authentication-agent-1"
          ];

          ########################################################################################
          # Env Vars
          ########################################################################################

          # Tell XWayland to use a cursor theme
          env = [
            "XCURSOR_SIZE,24"

            # Enable appications
            "MOZ_ENABLE_WAYLAND,1"
            "QT_QPA_PLATFORM,wayland"
          ];

          ########################################################################################
          # Monitors
          ########################################################################################

          monitor =
            map (
              monitor: "${monitor.name}, ${monitor.resolution}, ${monitor.position}, ${monitor.scale}"
            )
            cfg.monitors
            ++ [",preferred, auto, 1"];

          ########################################################################################
          # Workspaces
          ########################################################################################

          workspace = generateWorkspaceMonitorBindings cfg.workspaces;
        }
        // (generateMonitors cfg.monitors);
    };

    services = {
      dunst = import ./dunst.nix;
    };

    home = {
      packages = with pkgs; [
        hyprpaper
        wl-clipboard

        libnotify
        pamixer
      ];

      file = {
        ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
        ".config/hypr/img/background.png".source = ./background.png;
        ".config/hypr/img/lockscreen.png".source = ./lockscreen.png;
      };
      sessionVariables.NIXOS_OZONE_WL = "1";
    };
  };
}
