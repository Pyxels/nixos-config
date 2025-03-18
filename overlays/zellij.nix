(final: prev: {
  zellij = prev.zellij.overrideAttrs (_oldAttrs: rec {
    version = "0.43.0";
    src = final.fetchFromGitHub {
      owner = "zellij-org";
      repo = "zellij";
      rev = "5d5f58465ab9d39dbf08208213951e9c691470d7";
      sha256 = "sha256-biICdLPgfDVaHOrCx0N8F8hTp2rNEgwo5iVqJGeKELg=";
    };
    cargoDeps = final.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-DAtO30R+5P154XuF+BudygW8ozeLIOHUt0RNJA1EN5I=";
    };
  });
})
