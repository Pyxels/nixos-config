{
  pkgs,
  configPath,
  ...
}: let
  importShellBin = file: import file {inherit pkgs configPath;};
in {
  home.packages = map importShellBin [
    ./screenshot.nix
    ./headset_toggle.nix

    ./select_workspace.nix
    ./create_workspace.nix
    ./clipboard_history.nix
  ];
}
