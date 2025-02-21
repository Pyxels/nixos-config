{
  programs.bash.interactiveShellInit = let
    RED = "\\033[31m";
    YELLOW = "\\033[33m";
    BLUE = "\\033[34m";
    RESET = "\\033[0m";
  in ''
    if [ $( (readlink `readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules,systemd}`; \
             readlink /run/booted-system/{initrd,kernel,kernel-modules,systemd}) | sort -u | wc -l ) -ne 4 ]; then
      echo -e "\n${RED}Looks like the booted version does not match the current version kernel/initrd/systemd. Please reboot!${RESET}"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/initrd)" "$(readlink `readlink /nix/var/nix/profiles/system/initrd`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/kernel)" "$(readlink `readlink /nix/var/nix/profiles/system/kernel`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/kernel-modules)" "$(readlink `readlink /nix/var/nix/profiles/system/kernel-modules`)"
      printf "${BLUE}%-72s${YELLOW} -> ${RESET}%s\n" "$(readlink /run/booted-system/systemd)" "$(readlink `readlink /nix/var/nix/profiles/system/systemd`)"
    fi
  '';
}
