{
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "master";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_rsa.pub";
      interactive.singlekey = true;
      push.autoSetupRemote = true;

      user = {
        email = "39232833+Pyxels@users.noreply.github.com";
        name = "Pyxels";
      };
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
    options.display = "inline";
  };
}
