{pkgs, ...}:
pkgs.writeShellApplication {
  name = "create_workspace";

  runtimeInputs = with pkgs; [hyprland kickoff jq];

  text = ''
    predefined=" tmp
     YT"

    new_workspace=$(echo "$predefined" | kickoff --from-stdin --stdout --prompt 'Create Workspace:  ')
    activemonitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true).name')

    test -n "$new_workspace"

    # Bind new workspace to current active monitor and open
    hyprctl keyword wsbind "name:$new_workspace,$activemonitor"
    hyprctl dispatch workspace "name:$new_workspace"
  '';
}
