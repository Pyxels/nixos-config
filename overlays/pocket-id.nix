(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.5.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-U5tZq310A6hnDIG8CeJl58EWLSshbXVaKJGSzLUCMI4=";
    };
    vendorHash = "sha256-9zPajwpfjsItAx3WAk4JiVlraTGHmYhLJ6VKRulPFOI=";

    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-AZ8je9uaJ1h9wxfs2RtPr2Ki0QNYD0nDd2BZDj6/sl8=";
      });
    });
  });
})
