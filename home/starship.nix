{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = "$directory$git_branch$git_state$custom$git_status$nix_shell $fill $cmd_duration$line_break$character";

      continuation_prompt = "[❯❯ ](bold purple)";

      fill.symbol = " ";

      directory = {
        style = "fg:blue";
        read_only_style = "fg:red";
        read_only = "🔒";
        format = "[$read_only]($read_only_style)[$path]($style)";
        truncation_length = 4;
        truncation_symbol = ".../";
      };
      git_branch = {
        style = "fg:white";
        format = "[ $branch]($style)";
      };
      git_status = {
        format = "[( $ahead_behind$stashed)]($style)";
        ahead = "[󰜷 \${count} ](blue)";
        behind = "[󰜮 \${count} ](blue)";
        diverged = "[󰹺 \${ahead_count}/\${behind_count} ](blue)";
        stashed = "[ ](fg:white)";
      };
      custom.git_status_star = {
        format = "$output";
        command = ''
          ${lib.getExe pkgs.git} status --porcelain=v2 2>/dev/null | ${lib.getExe pkgs.gawk} '
          BEGIN { untracked=0; modified=0; staged=0 }
          {
            if ($1 == "?") untracked++
            else if ($2 ~ /^.[MADRCU]/) modified++
            else if ($2 ~ /^[MADRCU]/) staged++
          }
          END {
            if (modified > 0) print "\033[38;5;166m*" # Gruvbox Orange for modified
            else if (staged > 0) print "\033[38;5;142m*" # Gruvbox Green for staged
            else if (untracked > 0) print "\033[38;5;132m*" # Gruvbox Purple for untracked
          }'
        '';
        when = "${lib.getExe pkgs.git} rev-parse --is-inside-work-tree >/dev/null 2>&1";
        style = "bold";
      };
      git_state = {
        format = "\([ $state( $progress_current/$progress_total)]($style)\)";
        style = "fg:gray";
      };

      nix_shell = {
        style = "fg:#ebdbb2";
        format = "[ $symbol]($style)";
      };

      cmd_duration = {
        min_time = 0;
        format = "[$duration ]($style)";
      };
      character = {
        success_symbol = "[❯](bold purple)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
