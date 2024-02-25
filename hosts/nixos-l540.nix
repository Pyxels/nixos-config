{...}: {
  name = "nixos-l540";
  system = "x86_64-linux";
  modules = [
    ../home/theming.nix
    ../home/hyprland
    ../home/programs
    ../home/terminal.nix
  ];
}
