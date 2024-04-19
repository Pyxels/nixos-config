{ pkgs, ... }:

pkgs.writeShellScriptBin "create_workspace" ''

  set -e

  predefined=" tmp
   YT"

  new_workspace=$(echo "$predefined" | ${pkgs.kickoff}/bin/kickoff --from-stdin --stdout --prompt 'Create Workspace:  ')
  activemonitor=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).name')

  test -n "$new_workspace"

  # Bind new workspace to current active monitor and open
  ${pkgs.hyprland}/bin/hyprctl keyword wsbind "name:$new_workspace,$activemonitor"
  ${pkgs.hyprland}/bin/hyprctl dispatch workspace "name:$new_workspace"

''
