{pkgs, ...}: let
  importShellBin = file: import file {inherit pkgs;};
in {
  home.packages = map importShellBin [
    ./screenshot.nix
    ./headset_toggle.nix

    ./select_workspace.nix
    ./create_workspace.nix
    ./clipboard_history.nix
  ];
}
