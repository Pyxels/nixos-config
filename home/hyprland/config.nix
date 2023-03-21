{ configPath }: ''
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
  }

  decoration {
      rounding = 5
      inactive_opacity = 0.85
      blur_passes = 2
      blur_ignore_opacity = true

      drop_shadow = false
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
  # Monitors
  ########################################################################################

  monitor = eDP-1, preferred, auto, 1
  monitor =      , preferred, auto, 1

  # Default workspaces on startup
  workspace = eDP-1,  name:


  ########################################################################################
  # Window rules
  ########################################################################################


  windowrulev2 = bordercolor rgb(fb4934), fullscreen:1
  windowrulev2 = bordercolor rgb(d3869b), pinned:1

  # For downloading Linux ISOs obviously
  windowrulev2 = workspace name:, class:^(org.qbittorrent.qBittorrent)$
  windowrulev2 = workspace name:, title:^(WhatsApp — Mozilla Firefox)$
  windowrulev2 = workspace name:, class:^(discord)$
  windowrulev2 = workspace name:, class:^(ff_discord)$

  windowrulev2 = float, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = nofocus, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = move 100%-60 20, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = nofullscreenrequest, title:^(Firefox — Sharing Indicator)$
  windowrulev2 = nofullscreenrequest, class:^(firefox)$, title:^(Opening.*)$


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
  bind = SUPER, N, exec, alacritty -e qalc

  # Shortcuts
  bind = SUPER,       Period, exec, pamixer --allow-boost -i 2
  bind = SUPER_SHIFT, Period, exec, pamixer --allow-boost -i 10
  bind = SUPER,       Comma,  exec, pamixer --allow-boost -d 2
  bind = SUPER_SHIFT, Comma,  exec, pamixer --allow-boost -d 10
  bind = SUPER_SHIFT, B,      exec, sb-bluetooth_toggle
  bind = SUPER_SHIFT, L,      exec, swaylock -eFi ~/.config/hypr/img/lockscreen.png
  bind = SUPER,       P,      exec, ${configPath}/home/scripts/toggle_music

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
  bind = SUPER, 4, workspace, name:
  bind = SUPER, 5, workspace, name:
  bind = SUPER, 6, workspace, name:
  bind = SUPER, 7, workspace, name:
  bind = SUPER, 8, workspace, name:
  bind = SUPER, 9, workspace, name:
  bind = SUPER, 0, workspace, name:
  # Move active window to workspace
  bind = SUPER_SHIFT, 1, movetoworkspace, name:
  bind = SUPER_SHIFT, 2, movetoworkspace, name:
  bind = SUPER_SHIFT, 3, movetoworkspace, name:
  bind = SUPER_SHIFT, 4, movetoworkspace, name:
  bind = SUPER_SHIFT, 5, movetoworkspace, name:
  bind = SUPER_SHIFT, 6, movetoworkspace, name:
  bind = SUPER_SHIFT, 7, movetoworkspace, name:
  bind = SUPER_SHIFT, 8, movetoworkspace, name:
  bind = SUPER_SHIFT, 9, movetoworkspace, name:
  bind = SUPER_SHIFT, 0, movetoworkspace, name:


  # Interactive workspace selector/creator
  bind = SUPER,       Y, exec, ${configPath}/home/hyprland/select_workspace
  bind = SUPER_SHIFT, Y, exec, ${configPath}/home/hyprland/create_workspace

  # Move/resize windows with mainMod + LMB/RMB and dragging
  bindm = SUPER, mouse:272, movewindow
  bindm = SUPER, mouse:273, resizewindow

  ########################################################################################
  # Startup
  ########################################################################################

  exec-once = waybar & hyprpaper -n
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
  env = SUDO_ASKPASS,${configPath}/home/scripts/askpass_kickoff.sh
''
