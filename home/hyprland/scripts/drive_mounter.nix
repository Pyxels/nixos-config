{pkgs, ...}:
pkgs.writeShellApplication {
  name = "mounter";

  runtimeInputs = with pkgs; [jmtpfs kickoff libnotify];

  text = ''
    # Inspired by Luke Smith (https://github.com/LukeSmithxyz/voidrice/blob/master/.local/bin/mounter)
    # But very custom with my own ids

    while test -f "$XDG_RUNTIME_DIR"/kickoff/kickoff.pid; do
      sleep 0.2
    done

    # All connected phones
    phones=$(jmtpfs -l | grep -v "^\(Device\|Available\)" | awk -F', ' '{print "󰄜", $5, $6}')

    # All newly connected drives
    # Ignore my builtin Drives
    ignored="\(0A7E-9F09\|2a2035bd-f4fb-4742-b142-8659ed5cf5c7\|3A1094B410947919\|94ACCD36ACCD1420\|B6A2AA03A2A9C867\|6E03-F492\|FA7EC2E07EC294B3\|8679ec75-5790-4d21-90e7-dbab5e1e0d01\)"
    drives="$(lsblk -rpo "uuid,name,type,size,label,mountpoint,fstype")"
    filter() { sed "/$ignored/d" | sed "s/ /:/g" | awk -F':' '$7=="" {printf "%s %s (%s) %s\n",$1,$3,$5,$6}' ; }
    newparts="$(echo "$drives" | grep 'part\|rom\|crypt' | sed "s/^/ /" | filter )"

    alldrives=$(echo "$phones
    $newparts" | sed "/^$/d;s/ *$//")
    test -n "$alldrives"


    chosen=$(echo "$alldrives" | kickoff --from-stdin --stdout -p "Mount which drive/phone? ")

    # Function for prompting user for a mountpoint.
    getmount(){
        mp="$(echo -e "/mnt/usb\n/tmp/usb" | kickoff --from-stdin --stdout -p "Mount this where? " | sed 's/ *$//')"
        test -n "$mp"
        if [ ! -d "$mp" ]; then
            mkdiryn=$(printf "No\\nYes" | kickoff --from-stdin --stdout -p "$mp does not exist. Create it? ")
            if [ "$mkdiryn" = "Yes" ]; then
                (mkdir -p "$mp" || sudo -A mkdir -p "$mp")
            else
                exit 1
            fi
        fi
        if [ -n "$(ls -A "$mp")" ]; then
            notify-send " Drive not Mounted." "$mp is not empty"
            exit 1
        fi
    }

    case "$chosen" in
        *)
            dev=$(echo "$chosen" | sed "s/^.*\(\/dev\/[a-z]\{3\}[0-9]\).*$/\1/")
            getmount
            sudo -A mount "$dev" "$mp" && notify-send "💾Drive Mounted." "$dev mounted to $mp."
            ;;

        󰄜*)
            mp="/mnt/phone/"
            echo "Ok?" | kickoff --from-stdin --stdout -p "Tap Allow on your phone if it asks for permission and then press enter "
            sudo -A jmtpfs "$mp" -o allow_other,auto_unmount && notify-send "🤖 Android Mounted." "Android device mounted to $mp."
            ;;
    esac
  '';
}
