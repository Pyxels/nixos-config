{ inputs, config, pkgs, lib, host, name, configPath, ... }:

{
  home.username = name;
  home.homeDirectory = "/home/${name}";

  # dont change
  home.stateVersion = "22.11";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
