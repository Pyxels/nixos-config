{pkgs, ...}:
pkgs.writeShellApplication {
  name = "select_workspace";

  runtimeInputs = with pkgs; [hyprland jq kickoff];

  text = ''
    workspaces=$(hyprctl workspaces -j | jq -r '.[] | "\(.name) - \(.monitor)=\(.name),\(.id)"' )
    selection=$(echo "$workspaces" | kickoff --from-stdin --stdout --prompt "Select Workspace:  ")
    test -n "$selection"

    id=$(echo "$selection" | awk -F ',' '{print $NF}')
    name=$(echo "$selection" | awk -F ',' '{print $1}')

    # Check if workspace is a named workspace
    if [ "$id" -le -1337 ]; then
      goto="name:$name"
    else
      goto="$id"
    fi

    hyprctl dispatch workspace "$goto"
  '';
}
