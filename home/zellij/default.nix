_: {
  programs.zellij.enable = true;

  xdg.configFile = {
    zellij_config = {
      target = "zellij/config.kdl";
      source = ./zellij.kdl;
    };
    zellij_layout = {
      target = "zellij/layouts/default.kdl";
      source = ./default_layout.kdl;
    };
    zellij_theme = {
      target = "zellij/themes/gruvbox.kdl";
      source = ./gruvbox_with_selection.kdl;
    };
  };
}
