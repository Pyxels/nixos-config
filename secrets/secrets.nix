let
  jonas-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+pzjmsotqutUKGBpYBWyvyH1wQZJ/a4rOHaghaaCG/ jonas@nixos-l540";
  jonas-vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus";
  jonas-bits = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXebXmITS8OF3CLbwVC+HFRg8b/96FiEccvAfQV/ovZ jonas@jonas-bits";
  users = [jonas-l540 jonas-vetus jonas-bits];

  arm-vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLMDZFCA5FqnUaHSkIUt9+7u1f6xUwSwIXZ2j5kDV/c root@arm-vps";
  beelink = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnMRPNsqL8bVMlpSK/2YbcgWKosmWuoOEboOB8UniP root@beelink";
in {
  "wanderer.age".publicKeys = users ++ [beelink];
  "wandererMeiliKey.age".publicKeys = users ++ [beelink];
  "oauth2-proxy.age".publicKeys = users ++ [beelink];
  "beelink-private-domain.age".publicKeys = users ++ [beelink];
  "wireguard-conf.age".publicKeys = users ++ [beelink];
  "beelink-radarr-key.age".publicKeys = users ++ [beelink];
  "beelink-sonarr-key.age".publicKeys = users ++ [beelink];
  "beelink-prowlarr-key.age".publicKeys = users ++ [beelink];
  "beelink-jellyfin-exporter.age".publicKeys = users ++ [beelink];
  "beelink-grafana-secret-key.age".publicKeys = users ++ [beelink];
  "../modules/crowdsec/crowdsec-enroll-key.age".publicKeys = users ++ [beelink arm-vps];
  "../modules/crowdsec/crowdsec-firewall-key.age".publicKeys = users ++ [beelink arm-vps];
  "crowdsec-sync-ssh-key.age".publicKeys = users ++ [beelink];
  "pocket-id.age".publicKeys = users ++ [arm-vps];
}
