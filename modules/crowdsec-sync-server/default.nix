{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.customConfig.crowdsec-sync-server;
  # system-path wrapper that injects -c with the generated config path;
  # raw ${pkgs.crowdsec}/bin/cscli would fail to find /etc/crowdsec/config.yaml
  cscli = "/run/current-system/sw/bin/cscli";

  sudo = "/run/wrappers/bin/sudo";

  updateScript = pkgs.writeShellApplication {
    name = "crowdsec-sync-update";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      set -euo pipefail

      cmd="''${SSH_ORIGINAL_COMMAND:-}"
      read -r verb arg <<<"$cmd"

      if [ "$verb" != "update" ]; then
        echo "rejected: unknown verb" >&2
        exit 1
      fi

      if ! [[ "$arg" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "rejected: invalid ipv4" >&2
        exit 1
      fi

      state_dir="${cfg.stateDir}"
      cache="$state_dir/last-ip"
      new="$arg"

      if [ -f "$cache" ]; then
        old=$(cat "$cache")
        if [ "$old" = "$new" ]; then
          echo "noop: $new already cached"
          exit 0
        fi
        if [ -n "$old" ]; then
          ${sudo} ${cscli} allowlists remove ${cfg.allowlist} "$old" || true
        fi
      fi

      ${sudo} ${cscli} allowlists add ${cfg.allowlist} "$new" \
        --comment "beelink residential, auto-synced"

      ${sudo} ${cscli} decisions delete --ip "$new" || true
      ${sudo} ${cscli} alerts delete --ip "$new" || true

      echo "$new" > "$cache"
      echo "ok: $new"
    '';
  };
in {
  options.customConfig.crowdsec-sync-server = {
    enable = mkEnableOption "crowdsec allowlist sync receiver";
    allowlist = mkOption {
      type = types.str;
      default = "private";
      description = "Name of the CrowdSec allowlist to manage.";
    };
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/crowdsec-sync";
      description = "Directory holding the cached last-synced IP.";
    };
    clientPublicKey = mkOption {
      type = types.str;
      description = "SSH public key of the sync client (beelink).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [updateScript];

    users.users.crowdsec-sync = {
      isSystemUser = true;
      group = "crowdsec-sync";
      home = cfg.stateDir;
      createHome = true;
      shell = pkgs.bashInteractive;
      openssh.authorizedKeys.keys = [
        ''restrict,command="${lib.getExe updateScript}" ${cfg.clientPublicKey}''
      ];
    };
    users.groups.crowdsec-sync = {};

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 crowdsec-sync crowdsec-sync -"
    ];

    security.sudo.extraRules = [
      {
        users = ["crowdsec-sync"];
        commands = [
          {
            command = "${cscli} allowlists add ${cfg.allowlist} *";
            options = ["NOPASSWD" "SETENV"];
          }
          {
            command = "${cscli} allowlists remove ${cfg.allowlist} *";
            options = ["NOPASSWD" "SETENV"];
          }
          {
            command = "${cscli} decisions delete --ip *";
            options = ["NOPASSWD" "SETENV"];
          }
          {
            command = "${cscli} alerts delete --ip *";
            options = ["NOPASSWD" "SETENV"];
          }
        ];
      }
    ];
  };
}
