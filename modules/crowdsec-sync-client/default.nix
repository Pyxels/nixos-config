{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.customConfig.crowdsec-sync-client;

  syncScript = pkgs.writeShellApplication {
    name = "crowdsec-sync-push";
    runtimeInputs = [pkgs.curl pkgs.openssh pkgs.coreutils];
    text = ''
      set -euo pipefail

      state_dir="${cfg.stateDir}"
      cache="$state_dir/last-ip"
      key="${config.age.secrets.crowdsec-sync-ssh-key.path}"

      ip=$(curl -fsS --max-time 5 https://api.ipify.org \
           || curl -fsS --max-time 5 https://ifconfig.me \
           || curl -fsS --max-time 5 https://icanhazip.com)
      ip="''${ip//[$'\t\r\n ']}"

      if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "invalid ip fetched: $ip" >&2
        exit 1
      fi

      if [ -f "$cache" ] && [ "$(cat "$cache")" = "$ip" ]; then
        echo "noop: $ip unchanged"
        exit 0
      fi

      ssh -i "$key" \
          -o StrictHostKeyChecking=accept-new \
          -o UserKnownHostsFile="$state_dir/known_hosts" \
          -o BatchMode=yes \
          "${cfg.remoteUser}@${cfg.remoteHost}" "update $ip"

      echo "$ip" > "$cache"
    '';
  };
in {
  options.customConfig.crowdsec-sync-client = {
    enable = mkEnableOption "crowdsec allowlist sync sender";
    remoteHost = mkOption {
      type = types.str;
      description = "SSH host (tailscale hostname) of the sync receiver.";
    };
    remoteUser = mkOption {
      type = types.str;
      default = "crowdsec-sync";
      description = "SSH user on the receiver.";
    };
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/crowdsec-sync";
      description = "Directory holding cache and known_hosts.";
    };
    interval = mkOption {
      type = types.str;
      default = "1h";
      description = "Systemd OnUnitActiveSec value.";
    };
  };

  config = mkIf cfg.enable {
    age.secrets.crowdsec-sync-ssh-key = {
      file = ../../secrets/crowdsec-sync-ssh-key.age;
      mode = "0400";
      owner = "root";
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0700 root root -"
    ];

    systemd.services.crowdsec-sync = {
      description = "Push beelink public IP to arm-vps crowdsec allowlist";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = lib.getExe syncScript;
      };
    };

    systemd.timers.crowdsec-sync = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
        Unit = "crowdsec-sync.service";
      };
    };
  };
}
