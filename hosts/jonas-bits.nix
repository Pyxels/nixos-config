{...}: {
  name = "jonas-bits";
  system = "x86_64-linux";
  modules = [
    ../home/non_nixos.nix
    ../home/terminal.nix
  ];
}
