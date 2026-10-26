# All custom NixOS modules. Each one is gated behind `customConfig.<name>.enable`.
_: {
  imports = [
    ./caddy-oauth2
    ./crowdsec
    ./crowdsec-sync-client
    ./crowdsec-sync-server
    ./jellyfin-exporter
    ./reboot-required
  ];
}
