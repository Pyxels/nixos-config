(final: prev: {
  beszel = (prev.beszel.override {buildGoModule = final.buildGo124Module;}).overrideAttrs (oldAttrs: rec {
    version = "0.10.2";
    src = oldAttrs.src.override {
      tag = "v${version}";
      hash = "sha256-yYSX58qA4vE7Bp3ADc6rIMf9yaeU7Zw7D5rmES6x6oA=";
    };
    webui = oldAttrs.webui.overrideAttrs (oldWebui: rec {
      inherit src version;
      npmDeps = oldWebui.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-27NUV23dNHFSwOHiB/wGSAWkp6eZMnw/6Pd3Fwn98+s=";
        name = "${oldAttrs.pname}-${version}-npm-deps";
      });
    });
    vendorHash = "sha256-VX9mil0Hdmb85Zd9jfvm5Zz2pPQx+oAGHY+BI04bYQY=";
    preBuild = ''
      mkdir -p site/dist
      cp -r ${webui}/* site/dist
    '';
  });
})
