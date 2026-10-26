{
  pkgs,
  inputs,
  ...
}: let
  nix_run_local =
    pkgs.writeShellScriptBin "nr"
    ''
      nix run "${inputs.nixpkgs}#$@"
    '';

  nix_shell_local =
    pkgs.writeShellScriptBin "ns"
    ''
      PROMPT="nix shell"

      for program in "$@"; do
        PROMPT="$PROMPT ${inputs.nixpkgs}#$program"
      done

      eval "$PROMPT"
    '';
in {
  home.packages = [nix_run_local nix_shell_local];
}
