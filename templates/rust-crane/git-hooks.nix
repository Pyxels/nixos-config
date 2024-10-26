{
  pkgs,
  inputs,
  system,
  ...
}: let
  inherit (inputs) git-hooks;

  default-hooks = {
    src = ./.;
    hooks = {
      alejandra.enable = true;
      nil.enable = true;
      statix.enable = true;

      clippy.enable = true;
      rustfmt.enable = true;

      check-merge-conflicts.enable = true;
      commitizen.enable = true;
      no-commit-to-branch.enable = true;
      actionlint.enable = true;
      detect-private-keys.enable = true;
      editorconfig-checker.enable = true;
      check-added-large-files.enable = true;
      trim-trailing-whitespace.enable = true;

      check-todos = {
        enable = true;
        entry = "${pkgs.writeShellScript "check_todos.sh" ''
          ${pkgs.ripgrep}/bin/rg '\s*#\s+TODO' "$@" && exit 1 || exit 0
        ''}";
      };
    };
  };
in {
  default = git-hooks.lib.${system}.run default-hooks;
}
