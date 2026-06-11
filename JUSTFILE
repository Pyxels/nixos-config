default:
  @just --list

# deploy hosts with colmena (interactive: fzf select, nvd diff, dry-run, parallel)
deploy:
  #!/usr/bin/env bash
  set -euo pipefail

  # host list from colmena hive nodes
  all_hosts="$(nix eval --json .#colmenaHive --apply 'h: builtins.attrNames h.nodes' | tr -d '[]"' | tr ',' ' ')"

  # pick hosts (tab multi-select, enter confirm)
  hosts="$(printf '%s\n' $all_hosts | fzf --multi --prompt='hosts> ' \
    --header='TAB to select, ENTER to confirm')"
  if [ -z "$hosts" ]; then echo "no host selected, abort"; exit 1; fi

  ask() { # ask <prompt> <default y|n>
    local def="$2" hint ans
    [ "$def" = "y" ] && hint="[Y/n]" || hint="[y/N]"
    read -r -p "$1 $hint " ans
    ans="${ans:-$def}"
    case "$ans" in [Yy]*) return 0;; *) return 1;; esac
  }

  use_nvd=n; dry=n; par=n
  ask "run nvd diff?"      y && use_nvd=y || true
  ask "dry-activate only?" n && dry=y     || true
  ask "parallel?"          y && par=y     || true

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

# build the given host locally
build host:
  nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel -L

# use nh to rebuild and switch nixos
os:
  nh os switch

# use nh to rebuild and switch home-manager
home:
  nh home switch

