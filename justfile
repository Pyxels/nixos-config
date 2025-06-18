default:
  @just --list

# Deploy the given host without checks and with nom
deploy host:
  deploy -s -- .#{{host}} --log-format internal-json -v |& nom --json

# use nh to rebuild and switch nixos
os:
  nh os switch

# use nh to rebuild and switch home-manager
home:
  nh home switch

