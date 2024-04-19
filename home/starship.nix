{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = "$username[](fg:#3c3836 bg:#504945)$directory[](fg:#504945 bg:#665c54)$git_branch$git_status[](fg:#665c54 bg:#7c6f64)$nodejs$python$conda$rust$java$lua$nix_shell[](fg:#7c6f64 bg:#928374)$status[](fg:#928374)$fill[](#7c6f64)$cmd_duration[](bg:#7c6f64 fg:#665c54)$time$line_break$character";

      continuation_prompt = "▶▶ ";

      fill = {
        symbol = " ";
      };
      username = {
        show_always = true;
        style_user = "bg:#3c3836 fg:#a89984";
        style_root = "bg:#3c3836 fg:#a89984";
        format = "[ $user ]($style)";
      };
      directory = {
        style = "bg:#504945 fg:#bdae93";
        read_only_style = "bg:#504945 fg:red";
        format = "[ $read_only]($read_only_style)[$path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        read_only = "🔒";
      };
      git_branch = {
        symbol = "";
        style = "bg:#665c54 fg:#d5c4a1";
        format = "[ $symbol $branch ]($style)";
      };
      git_status = {
        style = "bg:#665c54";
        format = "[( $all_status$ahead_behind )]($style)";
        conflicted = "[ \${count} ](red bg:#665c54)";
        deleted = "[ \${count} ](fg:#f29218 bg:#665c54)";
        renamed = "[ \${count} ](fg:green bg:#665c54)";
        ahead = "[󰜷 \${count} ](blue bg:#665c54)";
        behind = "[󰜮 \${count} ](blue bg:#665c54)";
        diverged = "[󰜷 \${ahead_count} 󰜮 \${behind_count}](blue bg:#665c54)";
        untracked = "[ \${count} ](fg:#561a12 bg:#665c54)";
        stashed = "[ \${count} ](fg:#dede7c bg:#665c54)";
        modified = "[ \${count} ](fg:#f29218 bg:#665c54)";
        staged = "[ \${count} ](green bg:#665c54)";
      };
      nodejs = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ [$symbol](bg:#7c6f64 fg:#3c873a) ($version) ]($style)";
      };
      python = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ [$symbol](bg:#7c6f64 fg:#4584b6) ($version) ]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ [$symbol](bg:#7c6f64 fg:#CE422B) ($version) ]($style)";
      };
      java = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ [$symbol](bg:#7c6f64 fg:#f89820) ($version) ]($style)";
      };
      lua = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ [$symbol](bg:#7c6f64 fg:#000180) ($version) ]($style)";
      };
      package = {
        symbol = "";
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ $symbol ($version) ]($style)";
      };
      nix_shell = {
        style = "bg:#7c6f64 fg:#ebdbb2";
        format = "[ $symbol$name ]($style)";
      };
      status = {
        disabled = false;
        symbol = "";
        success_symbol = "[](fg:#fbf1c7 bg:#928374)";
        not_executable_symbol = "";
        not_found_symbol = "󰍉";
        sigint_symbol = "";
        signal_symbol = "";
        style = "bg:#928374 fg:red";
        format = "[ $symbol $common_meaning$signal_name$maybe_int]($style)";
        map_symbol = true;
      };
      cmd_duration = {
        min_time = 0;
        style = "bg:#7c6f64";
        format = "[  $duration ]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#665c54";
        format = "[ $time ]($style)";
      };
      character = {
        success_symbol = "[\\$ ❯](bold #96ce54)";
        error_symbol = "[\\$ ❯](bold red)";
      };
    };
  };
}
