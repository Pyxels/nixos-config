{name, ...}: {
  home = {
    username = name;
    homeDirectory = "/home/${name}";

    # dont change
    stateVersion = "22.11";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
