default:
  @just --list

# Deploy the given host without checks and with nom
deploy host:
  deploy -s -- .#{{host}} --log-format internal-json -v |& nom --json

# build the given host locally
build host:
  nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel -L

# use nh to rebuild and switch nixos
os:
  nh os switch

# use nh to rebuild and switch home-manager
home:
  nh home switch

