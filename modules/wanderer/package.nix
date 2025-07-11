{
  nixpkgs.overlays = [
    (final: prev: let
      version = "0.17.2";
      src = prev.pkgs.fetchFromGitHub {
        owner = "Flomp";
        repo = "wanderer";
        tag = "v${version}";
        sha256 = "sha256-Mpla2Y/lNJSqZHP1Du3OG86pkGJE88IlA8+RD9sCx8Y=";
      };
    in {
      wanderer-web-dist = prev.pkgs.buildNpmPackage {
        inherit version src;
        pname = "wanderer-web-dist";

        npmDepsHash = "sha256-fck1BYU59qW3RamUXk+gu9kA6EoUPU/8SERUr4o3x/E=";
        npmFlags = ["--legacy-peer-deps"];
        makeCacheWritable = true;
        sourceRoot = "${src.name}/web";

        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r build/ $out/dist
          cp -r node_modules $out/node_modules
          runHook postInstall
        '';
      };

      wanderer-web = prev.pkgs.writeShellApplication {
        name = "wanderer-web";
        text = "${prev.pkgs.nodejs_22}/bin/node ${final.wanderer-web-dist}/dist/";
      };

      wanderer-db = prev.pkgs.buildGoModule {
        inherit version src;
        pname = "wanderer-db";

        vendorHash = "sha256-giXDMG3o6mtG5sbgRdXT+YAxBCLXy4daLENR2NbK5qM=";
        sourceRoot = "${src.name}/db";

        postInstall = ''
          mkdir -p $out/share
          cp -r migrations templates $out/share/
        '';

        meta.mainProgram = "pocketbase";
      };
    })
  ];
}
