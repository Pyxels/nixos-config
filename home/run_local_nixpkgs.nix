{
  pkgs,
  nixpkgs,
  ...
}: let
  nix_run_local =
    pkgs.writeShellScriptBin "nr"
    ''
      nix run "${nixpkgs}#$@"
    '';

  nix_shell_local =
    pkgs.writeShellScriptBin "ns"
    ''
      PROMPT="nix shell"

      for program in "$@"; do
        PROMPT="$PROMPT ${nixpkgs}#$program"
      done

      eval "$PROMPT"
    '';
in {
  home.packages = [nix_run_local nix_shell_local];
}
