# Shared by every real machine (desktops and servers).
{
  lib,
  pkgs,
  ...
}: {
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true;
    };
  };

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
