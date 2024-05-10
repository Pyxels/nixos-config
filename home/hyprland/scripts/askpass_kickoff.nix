{
  pkgs,
  configPath,
}:
pkgs.writeShellScriptBin "askpass_kickoff" ''

  echo | ${pkgs.kickoff}/bin/kickoff --config ${configPath}/home/scripts/askpass_kickoff.toml --from-stdin --stdout

''
