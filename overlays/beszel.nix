(final: prev: {
  beszel = (prev.beszel.override {buildGoModule = final.buildGo124Module;}).overrideAttrs (oldAttrs: rec {
    version = "0.11.1";
    src = oldAttrs.src.override {
      tag = "v${version}";
      hash = "sha256-tAi48PAHDGIZn/HMsnCq0mLpvFSqUOMocq47hooiFT8=";
    };
    webui = oldAttrs.webui.overrideAttrs (oldWebui: rec {
      inherit src version;
      npmDeps = oldWebui.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-27NUV23dNHFSwOHiB/wGSAWkp6eZMnw/6Pd3Fwn98+s=";
        name = "${oldAttrs.pname}-${version}-npm-deps";
      });
    });
    vendorHash = "sha256-B6mOqOgcrRn0jV9wnDgRmBvfw7I/Qy5MNYvTiaCgjBE=";
    preBuild = ''
      mkdir -p site/dist
      cp -r ${webui}/* site/dist
    '';
  });
})
