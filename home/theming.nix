{
  pkgs,
  config,
  ...
}: {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt6;
  };
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    theme.package = pkgs.adw-gtk3;
    gtk4.theme = config.gtk.theme;
  };

  home.pointerCursor = {
    enable = true;
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    gtk.enable = true;
    x11.enable = true;
  };
}
