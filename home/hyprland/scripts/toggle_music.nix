{pkgs, ...}:
pkgs.writeShellApplication {
  name = "toggle_music";

  runtimeInputs = with pkgs; [socat mpv];

  text = ''
    socket=/tmp/mpvsocket
    if pidof mpv; then
        echo '{ "command": ["cycle", "pause"] }' | socat - $socket
    else
        mpv ~/Music/* --input-ipc-server=$socket &
    fi
  '';
}
