{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.customConfig.caddy-oauth2;

  mkOauth2Proxy = port: ''
    handle /oauth2/* {
      reverse_proxy ${cfg.proxyAddress} {
        header_up X-Real-IP ${cfg.realIpHeader}
        header_up X-Forwarded-Uri {uri}
      }
    }

    handle {
      forward_auth ${cfg.proxyAddress} {
        uri /oauth2/auth

        header_up X-Real-IP ${cfg.realIpHeader}

        @error status 401
        handle_response @error {
          redir * /oauth2/sign_in?rd={scheme}://{host}{uri}
        }
      }

      reverse_proxy http://127.0.0.1:${toString port}
    }
  '';
in {
  options.customConfig.caddy-oauth2 = {
    enable = mkEnableOption "caddy virtual hosts behind oauth2-proxy forward auth";
    virtualHosts = mkOption {
      type = types.attrsOf types.port;
      default = {};
      example = {"grafana.example.com" = 3000;};
      description = "Caddy virtual hosts to protect, mapped to the local port they proxy to.";
    };
    proxyAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:4180";
      description = "Address caddy uses to reach oauth2-proxy.";
    };
    realIpHeader = mkOption {
      type = types.str;
      default = "{remote_host}";
      description = "Caddy placeholder forwarded as X-Real-IP, e.g. the CF-Connecting-IP header behind cloudflare.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.services.oauth2-proxy.enable;
        message = "customConfig.caddy-oauth2 requires services.oauth2-proxy.enable";
      }
    ];

    services.caddy = {
      enable = true;
      virtualHosts = mapAttrs (_: port: {extraConfig = mkOauth2Proxy port;}) cfg.virtualHosts;
    };
  };
}
