{pkgs, ...}: {
  targets.genericLinux.enable = true;
  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
