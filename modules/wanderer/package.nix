{
  nixpkgs.overlays = [
    (final: prev: let
      version = "0.18.0";
      src = prev.pkgs.fetchFromGitHub {
        owner = "Flomp";
        repo = "wanderer";
        tag = "v${version}";
        sha256 = "sha256-RALi8HfKB7MnRfVb7MRiEtwu3d4CmtGa5A6tkui8VvI=";
      };
    in {
      wanderer-web-dist = prev.pkgs.buildNpmPackage {
        inherit version src;
        pname = "wanderer-web-dist";

        npmDepsHash = "sha256-rR+df6IS/jnmugotrPC8im73bLrTsF3onp2/x/m9cag=";
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

        vendorHash = "sha256-P8FOeQOl3601hTjq2gFcQyIu3Lt1gO1MOWoiLhjOs0A=";
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
