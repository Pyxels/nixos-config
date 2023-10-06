{ pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  qt.enable = true;
  qt.style.name = "adwaita-dark";
  gtk.enable = true;
  gtk.theme.name = "Adwaita-dark";

  home.pointerCursor = {
    name = "phinger-cursors";
    package = pkgs.phinger-cursors;
    gtk.enable = true;
  };
}
