{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt6;
  };
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    theme.package = pkgs.adw-gtk3;
  };

  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    gtk.enable = true;
    x11.enable = true;
  };
}
