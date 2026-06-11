{name, ...}: {
  programs.bash = {
    enable = true;
    sessionVariables = {
      NH_FLAKE = "/home/${name}/.dotfiles";
    };
    shellAliases = {
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
      df = "df -h";
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log";
      # ll="ls -lAhF";
      ll = "exa -laF --git --octal-permissions --no-permissions --time-style iso --group-directories-first";
      zf = "zathura --fork";
      dc = "docker compose";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };
    historyControl = ["ignoredups" "ignorespace"];
    historyFile = "/dev/null";
    historySize = 1000;
  };
}
