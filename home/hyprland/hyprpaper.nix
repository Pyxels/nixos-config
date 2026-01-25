{
  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          monitor = "";
          path = toString ./background.png;
        }
      ];
      splash = false;
    };
  };
}
