set positional-arguments

default:
  @just --list

# colmena deploy, prompts for what's not given (-y: defaults): [host...] [--[no-]nvd] [--[no-]dry] [--parallel|--seq] [-y]
deploy *args:
  #!/usr/bin/env bash
  set -euo pipefail

  usage() { echo "usage: just deploy [host...] [--nvd|--no-nvd] [--dry|--no-dry] [--parallel|--seq] [-y]"; }

  # host list from colmena hive nodes
  all_hosts="$(nix eval --json .#colmenaHive --apply 'h: builtins.attrNames h.nodes' | tr -d '[]"' | tr ',' ' ')"

  hosts=""; use_nvd=""; dry=""; par=""; yes=n
  for arg in "$@"; do
    case "$arg" in
      --nvd) use_nvd=y ;;
      --no-nvd) use_nvd=n ;;
      --dry) dry=y ;;
      --no-dry) dry=n ;;
      --parallel) par=y ;;
      --seq) par=n ;;
      -y|--yes) yes=y ;;
      -h|--help) usage; exit 0 ;;
      -*) echo "unknown flag: $arg"; usage; exit 1 ;;
      *)
        if [[ " $all_hosts " != *" $arg "* ]]; then echo "unknown host: $arg (have: $all_hosts)"; exit 1; fi
        hosts="$hosts $arg" ;;
    esac
  done

  # pick hosts (tab multi-select, ctrl-a toggle all, enter confirm)
  if [ -z "$hosts" ]; then
    hosts="$(printf '%s\n' $all_hosts | fzf --multi --prompt='hosts> ' \
      --header='TAB to select, CTRL-A to toggle all, ENTER to confirm')" || true
    if [ -z "$hosts" ]; then echo "no host selected, abort"; exit 1; fi
  fi

  ask() { # ask <prompt> <default y|n>, echoes y|n
    local def="$2" hint ans
    if [ "$yes" = "y" ]; then echo "$def"; return; fi
    [ "$def" = "y" ] && hint="[Y/n]" || hint="[y/N]"
    read -r -p "$1 $hint " ans
    ans="${ans:-$def}"
    case "$ans" in [Yy]*) echo y;; *) echo n;; esac
  }

  [ -n "$use_nvd" ] || use_nvd="$(ask "run nvd diff?" y)"
  [ -n "$dry" ]     || dry="$(ask "dry-activate only?" n)"
  [ -n "$par" ]     || par="$(ask "parallel?" y)"

  # colmena --on takes comma list; --parallel 1 forces sequential
  on="$(echo $hosts | tr ' ' ',')"
  par_flag=(--parallel 1); [ "$par" = "y" ] && par_flag=()

  bold="\033[1m"; green="\033[32m"; cyan="\033[36m"; yellow="\033[33m"; reset="\033[0m"
  flag() { [ "$1" = "y" ] && printf "%bon%b" "$green" "$reset" || printf "%boff%b" "$yellow" "$reset"; }
  printf "%b==> hosts:%b %b%s%b\n" "$bold" "$reset" "$cyan" "$on" "$reset"
  printf "    nvd=%b dry-activate=%b parallel=%b\n\n" \
    "$(flag $use_nvd)" "$(flag $dry)" "$(flag $par)"

  if [ "$dry" = "y" ]; then
    colmena apply --on "$on" "${par_flag[@]}" dry-activate
    exit
  fi

  declare -A old
  capture_old() { # $1=host
    old[$1]="$(ssh "$1" readlink -f /run/current-system)"
    nix copy --no-check-sigs --from "ssh://$1" "${old[$1]}"
  }
  show_diff() { # $1=host
    local new
    new="$(ssh "$1" readlink -f /run/current-system)"
    nix copy --no-check-sigs --from "ssh://$1" "$new"
    printf "%b==> %s%b\n" "$bold" "$1" "$reset"
    nvd diff "${old[$1]}" "$new"
  }

  if [ "$par" = "y" ]; then
    # colmena fans out; nvd capture/diff per host around the single apply
    if [ "$use_nvd" = "y" ]; then for host in $hosts; do capture_old "$host"; done; fi
    colmena apply --on "$on"
    if [ "$use_nvd" = "y" ]; then for host in $hosts; do show_diff "$host"; done; fi
  else
    # sequential: deploy + diff one host fully before next
    for host in $hosts; do
      printf "%b==> %s%b\n" "$bold" "$host" "$reset"
      if [ "$use_nvd" = "y" ]; then capture_old "$host"; fi
      colmena apply --on "$host"
      if [ "$use_nvd" = "y" ]; then show_diff "$host"; fi
    done
  fi

# build the given host locally (fzf select if omitted)
build host="":
  #!/usr/bin/env bash
  set -euo pipefail

  host="{{host}}"
  if [ -z "$host" ]; then
    all_hosts="$(nix eval --json .#nixosConfigurations --apply builtins.attrNames | tr -d '[]"' | tr ',' ' ')"
    host="$(printf '%s\n' $all_hosts | fzf --prompt='host> ')" || true
    if [ -z "$host" ]; then echo "no host selected, abort"; exit 1; fi
  fi

  nix build ".#nixosConfigurations.$host.config.system.build.toplevel" -L

# use nh to rebuild and switch nixos (includes home-manager on NixOS hosts)
os:
  nh os switch

# use nh to rebuild and switch standalone home-manager (non-NixOS hosts)
home:
  nh home switch

