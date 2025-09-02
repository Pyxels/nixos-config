(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.10.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-YAQT7ORRg27ORh57NTE8F89iNfw+3gd1xPM8f4zHKm4=";
    };
    vendorHash = "sha256-eNUhk76YLHtXCFaxiavM6d8CMeE+YQ+vOecDUCiTh5k=";

    frontend = oldAttrs.frontend.overrideAttrs (prev: {
      inherit version src;
      pnpmDeps = prev.pnpmDeps.overrideAttrs (_: {
        outputHash = "sha256-Gjj2iFQ15Tso0gXihFH96nW49GJleOU323shBE7VgJ4=";
      });
    });
  });
})
