{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "";
          path = toString (
            builtins.path {
              path = ./background.png;
              name = "desktop_background.png";
            }
          );
        }
      ];
      splash = false;
    };
  };
}
