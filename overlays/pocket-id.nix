(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.13.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-rXNHteSkRomRK+dlEq9E5l5K/gjiINW2HJ9wqsFYkDg=";
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
