{ pkgs, ... }:

pkgs.writeShellScriptBin "headset_toggle" ''

  id=30:50:75:48:AE:10

  if [[ $(${pkgs.bluez}/bin/bluetoothctl info $id | grep Connected | awk '{print $2}') == "yes" ]]
  then
    ${pkgs.libnotify}/bin/notify-send "Bluetooth " "Disconnecting $id"
    ${pkgs.bluez}/bin/bluetoothctl disconnect $id
    ${pkgs.dunst}/bin/dunstctl close
  else
    ${pkgs.libnotify}/bin/notify-send "Bluetooth " "Connecting to $id"
    ${pkgs.bluez}/bin/bluetoothctl connect $id
    ${pkgs.dunst}/bin/dunstctl close
  fi

''
