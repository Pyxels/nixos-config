{lib, ...}: {
  programs.zellij = let
    generateTabBindings = x:
      lib.listToAttrs (map (n: {
        name = "bind \"Alt ${toString n}\"";
        value = {GoToTab = n + 1;};
      }) (lib.range 0 x));
  in {
    enable = true;
    enableBashIntegration = false;
    settings = {
      default_mode = "locked";

      keybinds = {
        unbind = ["Ctrl h"];
        move."bind \"Ctrl b\"" = {SwitchToMode = "Normal";};
        search."bind \"N\"" = {Search = "up";};
        "shared_except \"move\" \"locked\""."bind \"Ctrl b\"" = {SwitchToMode = "Move";};
        locked = {
          "bind \"Alt h\"" = {MoveFocusOrTab = "Left";};
          "bind \"Alt l\"" = {MoveFocusOrTab = "Right";};
          "bind \"Alt j\"" = {MoveFocus = "Down";};
          "bind \"Alt k\"" = {MoveFocus = "Up";};
          "bind \"Alt w\"" = {ToggleFloatingPanes = {};};
        };
        shared = generateTabBindings 9;
      };

      theme = "gruvbox-dark";
      ui.pane_frames.hide_session_name = true;
      session_serialization = false;
    };
  };

  xdg.configFile = {
    zellij_layout = {
      target = "zellij/layouts/default.kdl";
      source = ./default_layout.kdl;
    };
    zellij_theme = {
      target = "zellij/themes/gruvbox.kdl";
      source = ./gruvbox_with_selection.kdl;
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      zellij = prev.zellij.overrideAttrs (_oldAttrs: rec {
        version = "0.42.0";
        src = final.fetchFromGitHub {
          owner = "pyxels";
          repo = "zellij";
          rev = "126491a7c6c88c41ac2088895471daf5d97260f5";
          sha256 = "sha256-fvTakUrriGPQ/ASowyPgo0Rk2ctQcMynx3Gm7rM9TnY=";
        };
        cargoDeps = final.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-TipkZXnXsSENJaTtyY3QLsVmHrhAgg8s39FKUysYJiY=";
        };
      });
    })
  ];
}
