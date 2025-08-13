(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (_oldAttrs: rec {
    version = "1.7.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-u4H1wC5RL3p7GNL7WQkmK8DNgwKQvgxHd8TIug+Be+o=";
    };
    vendorHash = "sha256-guG/JnwUi2WeClSfAX9pRG3kLJMTvTDiJ7L54TGeSd0=";

    frontend = final.stdenv.mkDerivation (finalAttrs: {
      pname = "pocket-id-frontend";
      inherit version src;

      nativeBuildInputs = [
        final.nodejs
        final.pnpm.configHook
      ];

      pnpmWorkspaces = ["pocket-id-frontend"];
      pnpmDeps = final.pnpm.fetchDeps {
        inherit
          (finalAttrs)
          pname
          version
          src
          pnpmWorkspaces
          ;
        fetcherVersion = 1;
        hash = "sha256-GSlyctAq7ubll9MtYy0lrAj9hh/bdWrQFh2fCu/dWuw=";
      };

      env.BUILD_OUTPUT_PATH = "dist";
      buildPhase = ''
        runHook preBuild

        pnpm --filter pocket-id-frontend run build

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/pocket-id-frontend
        cp -r frontend/dist $out/lib/pocket-id-frontend/dist

        runHook postInstall
      '';
    });
  });
})
