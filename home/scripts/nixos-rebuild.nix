{ pkgs, configPath }:

pkgs.writeShellScriptBin "nrs" ''

  sudo nixos-rebuild switch --flake ${configPath} |& ${pkgs.nix-output-monitor}/bin/nom || exit 1
  previous_config=$(ls -1 --sort=time /nix/var/nix/profiles/ | head -n 3 | tail -n 1)
  ${pkgs.nvd}/bin/nvd diff "/nix/var/nix/profiles/$previous_config" /nix/var/nix/profiles/system

''
