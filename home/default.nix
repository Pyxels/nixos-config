# Base home-manager config, shared by every home (NixOS hosts and standalone).
_: {
  home.stateVersion = "22.11"; # dont change

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
