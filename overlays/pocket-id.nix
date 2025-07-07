(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.6.1";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-a2ayPS6gD8w5fLu+4yC0E4Z/zeX7CHUQgWXgAgL0uKs=";
    };
    vendorHash = "sha256-LutjhewhizxGc/YlNHpK81HrX+wSAAJLWtA+skTjn1w=";

    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-AZ8je9uaJ1h9wxfs2RtPr2Ki0QNYD0nDd2BZDj6/sl8=";
      });
    });
  });
})
