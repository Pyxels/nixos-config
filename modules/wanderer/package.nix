{
  nixpkgs.overlays = [
    (final: prev: let
      version = "0.17.0";
      src = prev.pkgs.fetchFromGitHub {
        owner = "Flomp";
        repo = "wanderer";
        rev = "8e3eea6216fe8ff8355789e34a429dce338c1571";
        sha256 = "sha256-ihHcEMOegpKDXlqPztWpJwC84N15D1gUwsqQwGL7dTk=";
      };
    in {
      wanderer-web-dist = prev.pkgs.buildNpmPackage {
        inherit version src;
        pname = "wanderer-web-dist";

        npmDepsHash = "sha256-NwxmiGjiAqlt+9EjWIij4HdzGO48LShmGrelY+cXesY=";
        npmFlags = ["--legacy-peer-deps"];
        makeCacheWritable = true;
        sourceRoot = "${src.name}/web";

        patchPhase = ''
          runHook prePatch
          # https://github.com/Flomp/wanderer/issues/308#issuecomment-2911797555
          sed -i '9,17d' vite.config.ts
          runHook postPatch
        '';

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
