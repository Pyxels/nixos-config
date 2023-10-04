{ pkgs, configPath }:

pkgs.writeShellScriptBin "hms" ''

  ${pkgs.home-manager}/bin/home-manager switch --flake ${configPath} || exit 1
  previous_config=$(ls -1 --sort=time $NIX_USER_PROFILE_DIR/ | head -n 3 | tail -n 1)
  ${pkgs.nvd}/bin/nvd diff "$NIX_USER_PROFILE_DIR/$previous_config" "$NIX_USER_PROFILE_DIR/profile"

''
