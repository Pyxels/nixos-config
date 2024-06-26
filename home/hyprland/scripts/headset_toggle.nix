{pkgs, ...}:
pkgs.writeShellApplication {
  name = "headset_toggle";

  runtimeInputs = with pkgs; [bluez libnotify dunst];

  text = ''
    id=30:50:75:48:AE:10

    if [[ $(bluetoothctl info $id | grep Connected | awk '{print $2}') == "yes" ]]
    then
      notify-send "Bluetooth " "Disconnecting $id"
      bluetoothctl disconnect $id
      dunstctl close
    else
      notify-send "Bluetooth " "Connecting to $id"
      bluetoothctl connect $id
      dunstctl close
    fi
  '';
}
