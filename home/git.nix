{
  enable = true;

  userEmail = "39232833+Pyxels@users.noreply.github.com";
  userName = "Pyxels";

  extraConfig = {
    init.defaultBranch = "master";
    commit.gpgsign = true;
    gpg.format = "ssh";
    user.signingkey = "~/.ssh/id_rsa.pub";
  };

  delta.enable = true;
  delta.options = {
    light = false;
    line-numbers = true;
    features = "decorations";
    syntax-theme = "gruvbox-dark";
    decorations = {
      commit-decoration-style = "bold yellow box";
      file-style = "bold yellow";
      file-decoration-style = "none";
      hunk-header-decoration-style = "cyan";
    };
  };
}
