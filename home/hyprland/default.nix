{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.customConfig.hyprland;

  inherit (lib.generators) mkLuaInline;

  # A keybind is `hl.bind(key, dispatcher[, flags])`. Dispatchers are raw Lua
  # expressions (hl.dsp.*), so they are passed through mkLuaInline.
  mkBind = key: dispatcher: {_args = [key (mkLuaInline dispatcher)];};
  mkBindFlags = key: dispatcher: flags: {_args = [key (mkLuaInline dispatcher) flags];};
  mkExec = key: cmd: mkBind key ''hl.dsp.exec_cmd("${cmd}")'';

  generateWorkspaces = workspaces:
    lib.lists.flatten (
      map (ws: [
        (mkBind "SUPER + ${toString ws.number}" ''hl.dsp.focus({ workspace = "name:${ws.name}" })'')
        (mkBind "SUPER + SHIFT + ${toString ws.number}" ''hl.dsp.window.move({ workspace = "name:${ws.name}", follow = false })'')
      ])
      workspaces
    );

  generateWorkspaceMonitorBindings = workspaces:
    map (ws: {
      workspace = "name:${ws.name}";
      # Reference the monitor's Lua local (hyprlang `$foo` becomes Lua `foo`).
      monitor = mkLuaInline (lib.removePrefix "$" ws.monitor);
      default = ws.default or false;
    })
    workspaces;

  # Hyprlang `$foo = code` variables become Lua locals; the `$` is stripped so
  # the name is a valid Lua identifier.
  generateMonitors = monitors:
    builtins.listToAttrs (
      map (monitor: {
        name = lib.removePrefix "$" monitor.name;
        value = {_var = monitor.code;};
      })
      monitors
    );
in {
  imports = [
    ./waybar
    ./scripts
    ./hyprpaper.nix
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

      configType = "lua";
      settings =
        {
          # Static variables/sections all live inside a single `hl.config({...})` call.
          config = {
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
              col.active_border = {
                colors = ["rgba(33ccffee)" "rgba(00ff99ee)"];
                angle = 45;
              };

              layout = "master";
            };

            cursor = {
              inactive_timeout = 5;
              enable_hyprcursor = false;
            };

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
          };

          ########################################################################################
          # Animations
          ########################################################################################

          curve = {
            _args = [
              "myBezier"
              {
                type = "bezier";
                points = [[0.05 0.9] [0.1 1.05]];
              }
            ];
          };

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 5;
              bezier = "myBezier";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 5;
              bezier = "default";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 7;
              bezier = "default";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "default";
            }
          ];

          ########################################################################################
          # Window rules
          ########################################################################################

          window_rule = [
            {
              match.fullscreen = true;
              border_color = "rgb(fb4934)";
            }
            {
              match.pin = true;
              border_color = "rgb(d3869b)";
            }
          ];

          bind =
            [
              # Basic
              (mkExec "SUPER + Return" "${pkgs.alacritty}/bin/alacritty")
              (mkBind "SUPER + Q" "hl.dsp.window.close()")
              (mkBind "CTRL + ALT + BackSpace" "hl.dsp.exit()")

              # Applications
              (mkExec "SUPER + D" "${pkgs.kickoff}/bin/kickoff")
              (mkExec "SUPER + W" "${pkgs.firefox}/bin/firefox")
              (mkExec "SUPER + N" "${pkgs.alacritty}/bin/alacritty -e ${pkgs.libqalculate}/bin/qalc")

              # Shortcuts
              (mkExec "SUPER + Period" "${pkgs.pamixer}/bin/pamixer --allow-boost -i 2")
              (mkExec "SUPER + SHIFT + Period" "${pkgs.pamixer}/bin/pamixer --allow-boost -i 10")
              (mkExec "SUPER + Comma" "${pkgs.pamixer}/bin/pamixer --allow-boost -d 2")
              (mkExec "SUPER + SHIFT + Comma" "${pkgs.pamixer}/bin/pamixer --allow-boost -d 10")
              (mkExec "SUPER + SHIFT + B" "headset_toggle")
              (mkExec "SUPER + SHIFT + L" "${pkgs.swaylock}/bin/swaylock -eFi ~/.config/hypr/img/lockscreen.png")

              # Layout
              (mkBind "SUPER + Space" ''hl.dsp.layout("swapwithmaster master")'')
              (mkBind "SUPER + SHIFT + Space" ''hl.dsp.window.float({ action = "toggle" })'')
              (mkBind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'')
              (mkBind "SUPER + SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })'')
              (mkBind "SUPER + J" ''hl.dsp.layout("cyclenext")'')
              (mkBind "SUPER + K" ''hl.dsp.layout("cycleprev")'')
              (mkBind "SUPER + SHIFT + J" ''hl.dsp.layout("swapnext")'')
              (mkBind "SUPER + SHIFT + K" ''hl.dsp.layout("swapprev")'')
              (mkBind "SUPER + SHIFT + S" "hl.dsp.window.pin()")

              (mkBind "SUPER + SHIFT + Left" ''hl.dsp.layout("orientationleft")'')
              (mkBind "SUPER + SHIFT + Up" ''hl.dsp.layout("orientationtop")'')
              (mkBind "SUPER + SHIFT + Right" ''hl.dsp.layout("orientationright")'')
              (mkBind "SUPER + SHIFT + Down" ''hl.dsp.layout("orientationbottom")'')
              (mkBind "SUPER + C" ''hl.dsp.layout("orientationcenter")'')

              # Master split ratio (hyprlang `splitratio` -> master `mfact` layout message)
              (mkBind "SUPER + L" ''hl.dsp.layout("mfact +0.05")'')
              (mkBind "SUPER + H" ''hl.dsp.layout("mfact -0.05")'')

              # Interactive workspace selector/creator
              (mkExec "SUPER + Y" "select_workspace")
              (mkExec "SUPER + SHIFT + Y" "create_workspace")

              # Move/resize windows with mainMod + LMB/RMB and dragging
              (mkBindFlags "SUPER + mouse:272" "hl.dsp.window.drag()" {mouse = true;})
              (mkBindFlags "SUPER + mouse:273" "hl.dsp.window.resize()" {mouse = true;})
            ]
            ++ generateWorkspaces cfg.workspaces;

          ########################################################################################
          # Startup
          ########################################################################################

          on = {
            _args = [
              "hyprland.start"
              (mkLuaInline ''
                function()
                  hl.exec_cmd("waybar")
                end'')
            ];
          };

          ########################################################################################
          # Env Vars
          ########################################################################################

          # Tell XWayland to use a cursor theme
          env = [
            {_args = ["XCURSOR_SIZE" "24"];}

            # Enable appications
            {_args = ["MOZ_ENABLE_WAYLAND" "1"];}
            {_args = ["QT_QPA_PLATFORM" "wayland"];}
          ];

          ########################################################################################
          # Monitors
          ########################################################################################

          monitor =
            map (monitor: {
              output = mkLuaInline (lib.removePrefix "$" monitor.name);
              mode = monitor.resolution;
              position = monitor.position;
              scale = monitor.scale;
            })
            cfg.monitors
            ++ [
              {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = "1";
              }
            ];

          ########################################################################################
          # Workspaces
          ########################################################################################

          workspace_rule = generateWorkspaceMonitorBindings cfg.workspaces;
        }
        // (generateMonitors cfg.monitors);
    };

    services = {
      dunst = import ./dunst.nix;
      hyprpolkitagent.enable = true;
      hyprsunset.enable = true;
    };

    home = {
      packages = with pkgs; [
        wl-clipboard

        libnotify
        pamixer
      ];

      file = {
        ".config/hypr/img/lockscreen.png".source = ./lockscreen.png;
      };
      sessionVariables.NIXOS_OZONE_WL = "1";
    };
  };
}
