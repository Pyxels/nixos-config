{pkgs, ...}:
pkgs.writeShellApplication {
  name = "umounter";

  runtimeInputs = with pkgs; [kickoff libnotify];

  text = ''
    # Analogous to ./drive_mounter.nix

    while test -f "$XDG_RUNTIME_DIR"/kickoff/kickoff.pid; do
      sleep 0.2
    done

    mounteddroids="$(grep jmtpfs /etc/mtab | awk '{print "󰄜 " $2}')"
    lsblkoutput="$(lsblk -nrpo "name,type,size,mountpoint")"
    mounteddrives="$(echo "$lsblkoutput" | awk '$2=="part"&&$4!~/\/boot|\/home$|\/var\/log|\/mnt\/hdd_data|\/mnt\/2tb_hdd|SWAP/&&length($4)>1{printf " %s (%s)\n",$4,$3}')"

    allunmountable="$(echo "$mounteddroids
    $mounteddrives" | sed "/^$/d;s/ *$//")"
    echo "$allunmountable"
    test -n "$allunmountable"

    chosen="$(echo "$allunmountable" | kickoff --from-stdin --stdout -p "Unmount which drive? ")"
    chosen=$(echo "$chosen" | sed "s/^.* \(\/.*\)/\1/;s/ (.*)//")
    test -n "$chosen"

    sudo -A umount -l "$chosen" && notify-send "Device unmounted." "$chosen has been unmounted."
  '';
}
