{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];

  environment.systemPackages = [pkgs.neovim];
  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
  users.users.root.openssh.authorizedKeys.keys = (import ../../secrets/keys.nix).admins;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "de_DE.UTF-8";
  console.keyMap = "de";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking.hostName = "nixos";
}
