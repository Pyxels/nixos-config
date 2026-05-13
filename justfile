default:
  @just --list

# Deploy the given host with colmena
deploy host:
  colmena apply --on {{host}}

# build the given host locally
build host:
  nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel -L

# use nh to rebuild and switch nixos
os:
  nh os switch

# use nh to rebuild and switch home-manager
home:
  nh home switch

