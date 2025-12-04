{ config, ... }:
{
  config =
    let
      cfg-domain = config.kanidm-block.options.domain.top-level;
    in
    {
      security.acme = {
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
