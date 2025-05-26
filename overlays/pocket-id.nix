(final: prev: {
  pocket-id = prev.pocket-id.overrideAttrs (oldAttrs: rec {
    version = "1.0.0";
    src = final.fetchFromGitHub {
      owner = "pocket-id";
      repo = "pocket-id";
      tag = "v${version}";
      sha256 = "sha256-cHPG4KZgfLuEDzLJ9dV4PRUlqWjd7Ji3480lrFwK6Ds=";
    };
    backend = oldAttrs.backend.overrideAttrs (_oldBackend: {
      inherit src version;
      vendorHash = "sha256-82kdx9ihJgqMCiUjZTONGa1nCZoxKltw8mpF0KoOdT8=";
      preBuild = ''
        cp -r ${frontend}/dist ./frontend/dist
      '';
    });
    frontend = oldAttrs.frontend.overrideAttrs (oldFrontend: {
      inherit src version;
      BUILD_OUTPUT_PATH = "dist";
      npmDeps = oldFrontend.npmDeps.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-ykoyJtnqFK1fK60SbzrL7nhRcKYa3qYdHf9kFOC3EwE=";
        name = "${oldAttrs.pname}-${version}-npm-deps";
      });
      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r dist $out/

        runHook postInstall
      '';
    });

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      ln -s ${backend}/bin/pocket-id-backend $out/bin/pocket-id

      runHook postInstall
    '';
  });
})
