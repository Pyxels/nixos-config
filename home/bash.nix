name: {
  enable = true;
  shellAliases = {
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";
    df = "df -h";
    # ll="ls -lAhF";
    ll = "exa -laF --git --octal-permissions --no-permissions --time-style iso --group-directories-first";
    v = "nvim";
    zf = "zathura --fork";
    t = "taskwarrior-tui";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };
  historyControl = [ "ignoredups" "ignorespace" ];
  historyFile = "/home/${name}/.bash_history";
  historyFileSize = 1000;
  historySize = 1000;
  initExtra =
    ''
      case "$-" in *i*) ;; *) return ;; esac
      # always run ll after cd'ing into a directory
      function cd {
        builtin cd "$@" && ll
      }
    '';
}
