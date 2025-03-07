(final: prev: {
  beszel = (prev.beszel.override {buildGoModule = final.buildGo124Module;}).overrideAttrs (oldAttrs: rec {
    version = "0.10.1";
    src = oldAttrs.src.override {
      tag = "v${version}";
      hash = "sha256-4RuYZcBR7X9Ug6l91N/FtyfT38HlW2guputzo4kF8YU=";
    };
    webui = oldAttrs.webui.overrideAttrs (oldWebui: rec {
      inherit src version;
      npmDeps = oldWebui.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-UKOS7QyGsdKosjhxVhZErFkXhnfrFxdX0ozBUJGsNII=";
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
