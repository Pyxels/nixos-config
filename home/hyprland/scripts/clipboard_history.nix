{pkgs, ...}:
pkgs.writeShellApplication {
  name = "clipboard_history";

  runtimeInputs = with pkgs; [cliphist wl-clipboard kickoff];

  text = ''
    cliphist list \
      | kickoff --from-stdin --stdout --prompt "Clipboard:  " \
      | cliphist decode \
      | wl-copy
  '';
}
