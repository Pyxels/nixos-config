{ ... }: {
  programs.zellij.enable = true;

  xdg.configFile.zellij = {
    target = "zellij/config.kdl";
    source = ./zellij.kdl;
  };
  xdg.configFile.zellij_layout = {
    target = "zellij/layouts/default.kdl";
    source = ./default_layout.kdl;
  };
}
