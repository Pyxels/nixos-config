{
  enable = true;

  userEmail = "39232833+Pyxels@users.noreply.github.com";
  userName = "Pyxels";

  signing.key = "/home/jonas/.ssh/id_rsa.pub";
  signing.signByDefault = true;
  extraConfig = {
    init.defaultBranch = "master";
    commit.gpgsign = true;
    gpg.format = "ssh";
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
