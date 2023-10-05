{
  enable = true;
  settings = {
    global = {
      frame_width = 1;
      frame_color = "#788388";
      corner_radius = 4;
      font = "Noto Sans 15";
      markup = true;
      format = "<b>%s</b> %p\\n%b";
      sort = true;
      indicate_hidden = true;
      alignment = "left";
      show_age_threshold = 60;
      word_wrap = true;
      ignore_newline = false;
      width = 700;
      height = 300;
      origin = "top-center";
      offset = "10x50";
      scale = 0;
      shrink = true;
      transparency = 15;
      idle_threshold = 120;
      monitor = 0;
      follow = "keyboard";
      sticky_history = true;
      history_length = 20;
      show_indicators = true;
      line_height = 0;
      separator_height = 1;
      padding = 8;
      horizontal_padding = 10;
      separator_color = "#263238";
      browser = "firefox";
      icon_position = "left";
      max_icon_size = 32;
    };
    urgency_low = {
      background = "#263238";
      foreground = "#556064";
      timeout = 10;
    };
    urgency_normal = {
      background = "#1E1F29";
      foreground = "#F9FAF9";
      timeout = 10;
    };
    urgency_critical = {
      background = "#b71c1c";
      foreground = "#F9FAF9";
      timeout = 0;
    };
  };
}
