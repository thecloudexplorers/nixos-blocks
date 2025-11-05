{
  config,
  lib,
  ...
}:
{
  imports = [ ];

  options = {
    domain = {
      top-level = lib.mkOption {
        description = "Top level domain on which kanidm will work";
        type = lib.types.str;
        default = "example.tld";
        };
      };
    };

  config =
  let
    cfg-domain = config.domain;
  in {
    # enable kanidm service with config
    services.kanidm = {
        enableServer = true;
        # package = pkgs.kanidm_1_7;
        serverSettings = {
        domain = cfg-domain;
        origin = "https://login.${cfg-domain}";
        tls_key = "/var/lib/acme/login.${cfg-domain}/key.pem";
        tls_chain = "/var/lib/acme/login.${cfg-domain}/full.pem";
        role = "WriteReplica";
        ldapbindaddress = "[::]:636";
        bindaddress = "[::]:443";
        };
    };

    # open only secure firewall ports
    networking.firewall.allowedTCPPorts = [ 636 443 ];

    # make sure the certs are there before kanidm starts
    systemd.services.kanidm = {
        wants = [ "acme-login.${cfg-domain}.service" ];
        after = [ "acme-login.${cfg-domain}.service" ];
    };

    # make acme certificates accessible by kanidm
    security.acme.defaults.group = "certs";
    users.groups.certs.members = [ "kanidm" ];
  };
}
