# Standalone home-manager on the (non-NixOS) work laptop.
_: {
  imports = [
    ../../home
    ../../home/non_nixos.nix
    ../../home/terminal.nix
  ];

  home = {
    username = "jonas";
    homeDirectory = "/home/jonas";
  };
}
