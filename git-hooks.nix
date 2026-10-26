{
  inputs,
  system,
  pkgs,
}:
inputs.git-hooks.lib.${system}.run {
  src = ./.;
  package = pkgs.prek;
  hooks = {
    alejandra.enable = true;
    flake-checker.enable = true;
    nil.enable = true;
    deadnix = {
      enable = true;
      settings.exclude = [
        "./hosts/vetus/hardware.nix"
        "./hosts/nixos-l540/hardware.nix"
        "./templates/rust-crane/flake.nix"
        "./secrets/secrets.nix"
      ];
    };
    statix = {
      enable = true;
      settings.ignore = ["**/hardware.nix"];
    };

    shellcheck = {
      enable = true;
      excludes = [".*\.envrc$"];
    };
    actionlint.enable = true;
    commitizen.enable = true;
    check-merge-conflicts.enable = true;
  };
}
