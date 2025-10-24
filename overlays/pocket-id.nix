(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.14.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-5F3XchB3kl54Sm45yD9giRd1K3xwPNhFAVYILyY3f2Q=";
    };
    vendorHash = "sha256-CmhPURPNwcpmD9shLrQPVKFGBirEMjq0Z4lmgMCpxS8=";

    frontend = oldAttrs.frontend.overrideAttrs (prev: {
      inherit version src;
      pnpmDeps = prev.pnpmDeps.overrideAttrs (_: {
        outputHash = "sha256-/e1zBHdy3exqbMvlv0Jth7vpJd7DDnWXGfMV+Cdr56I=";
      });
    });
  });
})
