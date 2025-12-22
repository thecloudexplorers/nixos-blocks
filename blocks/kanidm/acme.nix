{ config, lib, ... }:
{
  config =
    let
      cfg-server-enable = config.nixos-blocks.kanidm.options.server.enable;
      cfg-domain = config.nixos-blocks.kanidm.options.domain.top-level;
    in
    {
      security.acme = lib.mkIf cfg-server-enable {
        defaults.reloadServices = [ "kanidm" ];
        certs."login.${cfg-domain}" = {
          domain = "login.${cfg-domain}";
          extraDomainNames = [
            "auth.${cfg-domain}"
            "idm.${cfg-domain}"
          ];
        };
      };
    };
}
