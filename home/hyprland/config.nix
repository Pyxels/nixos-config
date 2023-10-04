{ pkgs, configPath, host }: ''
  ########################################################################################
  # Variables
  ########################################################################################

  input {
      kb_layout = de
      kb_variant = nodeadkeys

      follow_mouse = 3
  }

  general {
      gaps_in = 3
      gaps_out = 10
      border_size = 2
      col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg

      cursor_inactive_timeout = 5

      layout = master
  }

  misc {
      # See: https://github.com/hyprwm/Hyprland/issues/1354
      mouse_move_focuses_monitor = false
      disable_hyprland_logo = true
  }

  decoration {
      rounding = 5
      inactive_opacity = 0.85
      drop_shadow = false

      blur {
          passes = 2
          ignore_opacity = true
      }
  }

  animations {
      enabled = true

      bezier = myBezier, 0.05, 0.9, 0.1, 1.05

      animation = windows,    1, 5,   myBezier
      animation = windowsOut, 1, 5,   default, popin 80%
      animation = border,     1, 10,  default
      animation = fade,       1, 7,   default
      animation = workspaces, 1, 6,   default
  }


  ########################################################################################
  # Layout Config
  ########################################################################################

  master {
      new_is_master = false
  }


  ########################################################################################
  # Window rules
  ########################################################################################


  windowrulev2 = bordercolor rgb(fb4934), fullscreen:1
  windowrulev2 = bordercolor rgb(d3869b), pinned:1

  # For downloading Linux ISOs obviously
  windowrulev2 = workspace name:, title:^(WhatsApp — Mozilla Firefox)$
  windowrulev2 = workspace name:, class:^(discord)$

  windowrulev2 = nofullscreenrequest, class:^(firefox)$, title:^(Opening.*)$
  windowrulev2 = float, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = nofocus, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = move 100%-530 20, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = nofullscreenrequest, title:^(Firefox — Sharing Indicator)$


  ########################################################################################
  # Keybinds
  ########################################################################################

  # Basic
  bind = SUPER,    Return,      exec, alacritty
  bind = SUPER,    Q,           killactive,
  bind = CTRL_ALT, BackSpace,   exit,
  bind = CTRL_ALT, Enter,       exec, alacritty

  # Applications
  bind = SUPER, D, exec, kickoff
  bind = SUPER, W, exec, firefox
  bind = SUPER, N, exec, alacritty -e ${pkgs.libqalculate}/bin/qalc

  # Shortcuts
  bind = SUPER,       Period, exec, pamixer --allow-boost -i 2
  bind = SUPER_SHIFT, Period, exec, pamixer --allow-boost -i 10
  bind = SUPER,       Comma,  exec, pamixer --allow-boost -d 2
  bind = SUPER_SHIFT, Comma,  exec, pamixer --allow-boost -d 10
  bind = SUPER_SHIFT, B,      exec, headset_toggle
  bind = SUPER_SHIFT, L,      exec, swaylock -eFi ~/.config/hypr/img/lockscreen.png
  bind = SUPER,       P,      exec, toggle_music

  # Layout
  bind = SUPER,       Space,  layoutmsg, swapwithmaster master
  bind = SUPER_SHIFT, Space,  togglefloating,
  bind = SUPER,       F,      fullscreen, 1
  bind = SUPER_SHIFT, F,      fullscreen, 0
  bind = SUPER,       J,      layoutmsg, cyclenext
  bind = SUPER,       K,      layoutmsg, cycleprev
  bind = SUPER_SHIFT, J,      layoutmsg, swapnext
  bind = SUPER_SHIFT, K,      layoutmsg, swapprev
  bind = SUPER_SHIFT, S,      pin,

  bind = SUPER_SHIFT, Left,   layoutmsg, orientationleft
  bind = SUPER_SHIFT, Up,     layoutmsg, orientationtop
  bind = SUPER_SHIFT, Right,  layoutmsg, orientationright
  bind = SUPER_SHIFT, Down,   layoutmsg, orientationbottom
  bind = SUPER,       C,      layoutmsg, orientationcenter

  bind = SUPER, L, splitratio, +0.05
  bind = SUPER, H, splitratio, -0.05


  # Switch workspaces
  bind = SUPER, 1, workspace, name:
  bind = SUPER, 2, workspace, name:
  bind = SUPER, 3, workspace, name:
  bind = SUPER, 4, workspace, name:󰈙
  bind = SUPER, 5, workspace, name:
  bind = SUPER, 6, workspace, name:
  bind = SUPER, 7, workspace, name:
  bind = SUPER, 8, workspace, name:󰎄
  bind = SUPER, 9, workspace, name:
  bind = SUPER, 0, workspace, name:
  # Move active window to workspace
  bind = SUPER_SHIFT, 1, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 2, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 3, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 4, movetoworkspacesilent, name:󰈙
  bind = SUPER_SHIFT, 5, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 6, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 7, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 8, movetoworkspacesilent, name:󰎄
  bind = SUPER_SHIFT, 9, movetoworkspacesilent, name:
  bind = SUPER_SHIFT, 0, movetoworkspacesilent, name:


  # Interactive workspace selector/creator
  bind = SUPER,       Y, exec, select_workspace
  bind = SUPER_SHIFT, Y, exec, create_workspace

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindm = SUPER, mouse:272, movewindow
  bindm = SUPER, mouse:273, resizewindow

  ########################################################################################
  # Startup
  ########################################################################################

  exec-once = waybar
  exec-once = hyprpaper -n
  exec-once = polkit-kde-authentication-agent-1


  ########################################################################################
  # Env Vars
  ########################################################################################

  # Log WLR errors and logs to the hyprland log. Recommended
  env = HYPRLAND_LOG_WLR,1

  # Tell XWayland to use a cursor theme
  env XCURSOR_SIZE,24
  # env XCURSOR_THEME,Breeze_Hacked

  # Enable appications
  env = MOZ_ENABLE_WAYLAND,1
  env = QT_QPA_PLATFORM,wayland

  # etc
  env = SUDO_ASKPASS,askpass_kickoff
''
+ (if host.name == "vetus" then ''
  ########################################################################################
  # Monitors
  ########################################################################################

  $left_mon = DVI-D-1
  $center_mon = DP-2
  $right_mon = DP-1

  monitor = $left_mon,    preferred, 0x0,     1
  monitor = $center_mon,  preferred, 1920x0,  1.5
  monitor = $right_mon,   preferred, 4480x0,  1
  # Fallback
  monitor = ,             preferred, auto,    1


  ########################################################################################
  # Workspaces
  ########################################################################################

  workspace = name:, monitor:$left_mon, default:false

  workspace = name:,       monitor:$center_mon, default:false
  workspace = name:,       monitor:$center_mon, default:false
  workspace = name:,       monitor:$center_mon, default:false
  workspace = name:,       monitor:$center_mon, default:false

  workspace = name:, monitor:$right_mon, default:false
  workspace = name:󰈙, monitor:$right_mon, default:false
  workspace = name:, monitor:$right_mon, default:false
  workspace = name:󰎄, monitor:$right_mon, default:false
  workspace = name:, monitor:$right_mon, default:false


  # Default workspaces on startup
  workspace = name: , monitor:$center_mon, default:true
  workspace = name: , monitor:$left_mon,   default:true
  workspace = name: , monitor:$right_mon,  default:true
''
else
  (if host.name == "nixos-l540" then ''
    ########################################################################################
    # Monitors
    ########################################################################################

    monitor = eDP-1, preferred, auto, 1
    monitor =      , preferred, auto, 1

    # Default workspaces on startup
    workspace = name: , monitor:eDP-1, default:true


  '' else ""))
