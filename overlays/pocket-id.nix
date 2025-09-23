(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.11.2";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-thKPYbHx9w75hUgWkLS5fX4R3QLLqFtAJqcvfTxAFiY=";
    };
    vendorHash = "sha256-+HF1zAWA6Ak7uJqWCcTXrttTy1sPA8bN+/No95eqFTU=";

    frontend = oldAttrs.frontend.overrideAttrs (prev: {
      inherit version src;
      pnpmDeps = prev.pnpmDeps.overrideAttrs (_: {
        outputHash = "sha256-IVrp5qWYMgud9ryLidrUowWWBHZ2lMrJp0cfPPHpXls=";
      });
    });
  });
})
