name: {
  enable = true;
  sessionVariables = {
    FLAKE = "/home/${name}/.dotfiles";
  };
  shellAliases = {
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";
    df = "df -h";
    # ll="ls -lAhF";
    ll = "exa -laF --git --octal-permissions --no-permissions --time-style iso --group-directories-first";
    v = "nvim";
    zf = "zathura --fork";
    dc = "docker-compose";
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
  };
  historyControl = [ "ignoredups" "ignorespace" ];
  historyFile = "/home/${name}/.bash_history";
  historyFileSize = 50000;
  historySize = 10000;
  initExtra =
    ''

      # more complex alias for nix run and nix shell
      nr() {
        nix run nixpkgs#"$@"
      }
      ns() {
        nix shell nixpkgs#"$@"
      }

      case "$-" in *i*) ;; *) return ;; esac
      # always run ll after cd'ing into a directory
      function cd {
        builtin cd "$@" && ll
      }
    '';
}
