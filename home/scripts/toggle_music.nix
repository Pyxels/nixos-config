{ pkgs, ... }:

pkgs.writeShellScriptBin "toggle_music" ''

  socket=/tmp/mpvsocket
  if pidof mpv; then
      echo '{ "command": ["cycle", "pause"] }' | ${pkgs.socat}/bin/socat - $socket
  else
      ${pkgs.mpv}/bin/mpv ~/Music/* --input-ipc-server=$socket &
  fi

''
