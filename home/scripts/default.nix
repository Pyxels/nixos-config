{ pkgs, configPath }:
let
  importShellBin = file: import file { inherit pkgs configPath; };
in
map importShellBin [
  ./home-manager_switch.nix
  ./nixos-rebuild.nix

  ./screenshot.nix
  ./askpass_kickoff.nix
  ./headset_toggle.nix
  ./toggle_music.nix
  ./drive_mounter.nix
  ./drive_unmounter.nix

  ./select_workspace.nix
  ./create_workspace.nix
]
