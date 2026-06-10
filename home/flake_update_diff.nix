{pkgs, ...}: let
  flake_update_diff = pkgs.writeShellApplication {
    name = "fud";
    runtimeInputs = [pkgs.nvd pkgs.nix];
    text = ''
      # flake update + diff: build current devShell, update lock, build new
      # devShell, diff closures with nvd.
      system="$(nix eval --raw --impure --expr 'builtins.currentSystem')"
      attr=".#devShells.$system.default"

      old="$(mktemp -d)/old"
      new="$(mktemp -d)/new"

      echo ">>> building current devShell"
      nix build "$attr" --out-link "$old"

      echo ">>> updating flake inputs"
      nix flake update

      echo ">>> building new devShell"
      nix build "$attr" --out-link "$new"

      echo ">>> diff"
      nvd diff "$old" "$new"
    '';
  };
in {
  home.packages = [flake_update_diff];
}
