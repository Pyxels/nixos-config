{pkgs, ...}: {
  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = import ./programs/alacritty.nix;
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
