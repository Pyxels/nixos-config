{ pkgs, ... }:

pkgs.writeShellScriptBin "select_workspace" ''

  set -e

  workspaces=$(${pkgs.hyprland}/bin/hyprctl workspaces -j | ${pkgs.jq}/bin/jq -r '.[] | "\(.name) - \(.monitor)=\(.name),\(.id)"' )
  selection=$(echo "$workspaces" | ${pkgs.kickoff}/bin/kickoff --from-stdin --stdout --prompt "Select Workspace:  ")
  test -n "$selection"

  id=$(echo "$selection" | awk -F ',' '{print $NF}')
  name=$(echo "$selection" | awk -F ',' '{print $1}')

# Check if workspace is a named workspace
  if [ "$id" -le -1337 ]; then
    goto="name:$name"
  else
    goto="$id"
  fi

  ${pkgs.hyprland}/bin/hyprctl dispatch workspace "$goto"

''
