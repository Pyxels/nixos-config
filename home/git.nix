{
  programs.git = {
    enable = true;

    userEmail = "39232833+Pyxels@users.noreply.github.com";
    userName = "Pyxels";

    extraConfig = {
      init.defaultBranch = "master";
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/id_rsa.pub";
    };

    difftastic.enable = true;
    difftastic.display = "inline";
  };
}
