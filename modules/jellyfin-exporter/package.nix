{pkgs, ...}: let
  pythonEnv = pkgs.python3.withPackages (ps:
    with ps; [
      requests
      prometheus_client
    ]);
in {
  nixpkgs.overlays = [
    (_final: _prev: {
      jellyfin-exporter = pkgs.stdenv.mkDerivation {
        pname = "jellyfin-exporter";
        version = "1.1.1";
        src = pkgs.fetchFromGitHub {
          owner = "drkhsh";
          repo = "jellyfin-exporter";
          rev = "dce447085393a454f3878cfabd497eae441363f8";
          sha256 = "sha256-A+ZKQX5WWeljOdzX6pbscdUatjGnGJxbbhJcgY8lcyc=";
        };

        buildInputs = [pythonEnv];

        installPhase = ''
          mkdir -p $out/bin
          cp jellyfin_exporter.py $out/bin/jellyfin_exporter
          chmod +x $out/bin/jellyfin_exporter
        '';

        meta = {
          description = "A Prometheus exporter for Jellyfin";
          homepage = "https://github.com/drkhsh/jellyfin-exporter";
          license = pkgs.lib.licenses.isc;
          mainProgram = "jellyfin_exporter";
        };
      };
    })
  ];
}
