{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./acme.nix ];

  options = {
    # TODO: add enable/disable
    nixos-blocks.kanidm.options = {
      domain = {
        top-level = lib.mkOption {
          description = "Top level domain on which kanidm will work";
          type = lib.types.str;
          default = "example.tld";
        };
      };
      package = lib.mkOption {
        description = "KanIDM package version";
        type = lib.types.package;
        default = "pkgs.kanidm_1_8";
      };
      role = lib.mkOption {
        description = "The role of this server. This affects the replication relationship and thereby available features.";
        default = "WriteReplica";
        type = lib.types.enum [
          "WriteReplica"
          "WriteReplicaNoUI"
          "ReadOnlyReplica"
        ];
      };
    };
  };

  config =
    let
      cfg-domain = config.nixos-blocks.kanidm.options.domain.top-level;
      cfg-package = config.nixos-blocks.kanidm.options.package;
      cfg-role = config.nixos-blocks.kanidm.options.role;
    in
    {
      # enable kanidm service with config
      services.kanidm = {
        enableServer = true;
        package = lib.mkForce cfg-package;
        serverSettings = {
          domain = cfg-domain;
          origin = "https://login.${cfg-domain}";
          tls_key = "/var/lib/acme/login.${cfg-domain}/key.pem";
          tls_chain = "/var/lib/acme/login.${cfg-domain}/full.pem";
          role = cfg-role;
          ldapbindaddress = "[::]:636";
          bindaddress = "[::]:443";
        };
      };

      # open only secure firewall ports
      networking.firewall.allowedTCPPorts = [
        636
        443
      ];

      environment.systemPackages = with pkgs; [
        kanidm
      ];

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
