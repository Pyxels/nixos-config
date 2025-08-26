(final: prev: {
  pocket-id =
    (prev.pocket-id.override {buildGoModule = final.buildGo125Module;}).overrideAttrs
    (oldAttrs: rec {
      version = "1.9.1";
      src = final.fetchFromGitHub {
        owner = "pocket-id";
        repo = "pocket-id";
        tag = "v${version}";
        sha256 = "sha256-3sUkEbC96/XUR1tvCmxu56hPh7Ag/sD6/pGrq9JhHC8=";
      };
      vendorHash = "sha256-eNUhk76YLHtXCFaxiavM6d8CMeE+YQ+vOecDUCiTh5k=";

      frontend = oldAttrs.frontend.overrideAttrs (prev: {
        inherit version src;
        pnpmDeps = prev.pnpmDeps.overrideAttrs (_: {
          outputHash = "sha256-q2oXyFVdaDfJ4NFDt26/VJVXzQLCuKXHtCx1mah6Js8=";
        });
      });
    });
})
