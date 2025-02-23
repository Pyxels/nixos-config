{
  inputs,
  system,
}:
inputs.git-hooks.lib.${system}.run {
  src = ./.;
  hooks = {
    alejandra.enable = true;
    flake-checker.enable = true;
    nil.enable = true;
    deadnix = {
      enable = true;
      settings.exclude = [
        "./nixos/vetus/hardware-configuration.nix"
        "./nixos/nixos-l540/hardware-configuration.nix"
        "./templates/rust-crane/flake.nix"
        "./secrets/secrets.nix"
      ];
    };
    statix = {
      enable = true;
      settings.ignore = ["**/*hardware-configuration.nix" "**/arm-vps/configuration.nix"];
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
