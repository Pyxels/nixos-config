let
  keys = import ./keys.nix;
  users = with keys.users; [jonas-l540 jonas-vetus jonas-bits];
  inherit (keys.hosts) arm-vps beelink;
in {
  "oauth2-proxy.age".publicKeys = users ++ [beelink];
  "beelink-private-domain.age".publicKeys = users ++ [beelink];
  "wireguard-conf.age".publicKeys = users ++ [beelink];
  "beelink-radarr-key.age".publicKeys = users ++ [beelink];
  "beelink-sonarr-key.age".publicKeys = users ++ [beelink];
  "beelink-prowlarr-key.age".publicKeys = users ++ [beelink];
  "beelink-jellyfin-exporter.age".publicKeys = users ++ [beelink];
  "beelink-grafana-secret-key.age".publicKeys = users ++ [beelink];
  "crowdsec-enroll-key.age".publicKeys = users ++ [beelink arm-vps];
  "crowdsec-sync-ssh-key.age".publicKeys = users ++ [beelink];
  "pocket-id.age".publicKeys = users ++ [arm-vps];
  "arm-vps-oauth2-proxy.age".publicKeys = users ++ [arm-vps];
}
