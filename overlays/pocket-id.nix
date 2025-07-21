(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.6.4";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-P6pA0760eo/dL1t5Jics4oSztM4F/C8lIuZ3dZ9x5C8=";
    };
    vendorHash = "sha256-8D7sSmxR+Fq4ouB9SuoEDplu6Znv3U0BIyYISSmF6Bs=";

    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-FiFSnN6DOMr8XghvyGTWB/EMTNfvpqlAgx7FPnbGQxU=";
      });
    });
  });
})
