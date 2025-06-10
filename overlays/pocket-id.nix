(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.3.1";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-I2wKxeXxGO8mx8pHzn/8mAqWsWBrMdFrznmkfEiBzpI=";
    };
    vendorHash = "sha256-9zPajwpfjsItAx3WAk4JiVlraTGHmYhLJ6VKRulPFOI=";

    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-CmlYMqRb4+CC0VgpTQKOakc1k6mSIIYbn6l7URu6Eck=";
        # name = "${oldAttrs.pname}-${version}-npm-deps";
      });
    });
  });
})
