{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./acme.nix ];

  options = {
    nixos-blocks.kanidm.options = {
      server = {
        enable = lib.mkOption {
          description = "Global switch to enable/disable the kanidm server component.";
          default = false;
          type = lib.types.bool;
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
      client = {
        enable = lib.mkOption {
          description = "Global switch to enable/disable the kanidm client component.";
          default = false;
          type = lib.types.bool;
        };
        posix-group = lib.mkOption {
          description = "Your kanidm POSIX group to allow for local logins";
          type = lib.types.listOf lib.types.str;
          default = "posix-users";
        };
        posix-group-prefix = lib.mkOption {
          description = "The common prefix you've given your POSIX-enabled groups. e.g. users would become posix_users if you'd enter posix_ here";
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        posix-group-suffix = lib.mkOption {
          description = "The common suffix you've given your POSIX-enabled groups. e.g. users would become users_posix if you'd enter _posix here";
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        local-account-override = lib.mkOption {
          description = "If you've specified local accounts to enable home manager, add them here to allow override by kanidm";
          type = lib.types.listOf lib.types.str;
          default = "";
        };
      };
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
    };
  };

  config =
    let
      cfg-server-enable = config.nixos-blocks.kanidm.options.server.enable;
      cfg-server-role = config.nixos-blocks.kanidm.options.role;
      cfg-client-enable = config.nixos-blocks.kanidm.options.client.enable;
      cfg-client-posix-group = config.nixos-blocks.kanidm.options.client.posix-group;
      cfg-client-posix-group-prefix = config.nixos-blocks.kanidm.options.client.posix-group-prefix;
      cfg-client-posix-group-suffix = config.nixos-blocks.kanidm.options.client.posix-group-suffix;
      cfg-client-local-account-override =
        config.nixos-blocks.kanidm.options.client.local-account-override;
      cfg-domain = config.nixos-blocks.kanidm.options.domain.top-level;
      cfg-package = config.nixos-blocks.kanidm.options.package;
    in
    {
      # enable kanidm service with config
      services.kanidm = {
        enableServer = cfg-server-enable;
        enableClient = cfg-client-enable;
        enablePam = cfg-client-enable;
        package = lib.mkForce cfg-package;
        serverSettings = {
          domain = cfg-domain;
          origin = "https://login.${cfg-domain}";
          tls_key = "/var/lib/acme/login.${cfg-domain}/key.pem";
          tls_chain = "/var/lib/acme/login.${cfg-domain}/full.pem";
          role = cfg-server-role;
          ldapbindaddress = "[::]:636";
          bindaddress = "[::]:443";
        };
        clientSettings = {
          uri = "https://login.${cfg-domain}";
        };
        unixSettings = {
          conn_timeout = 3;
          cache_timeout = 60;
          hsm_type = "tpm_if_possible";
          pam_allowed_login_groups = cfg-client-posix-group;
          version = "2";
          default_shell = "${pkgs.zsh}/bin/zsh";
          home_prefix = "/home/";
          home_attr = "uuid";
          home_alias = "name";
          uid_attr_map = "name";
          gid_attr_map = "name";
          allow_local_account_override = cfg-client-local-account-override;
          kanidm = {
            pam_allowed_login_groups = cfg-client-posix-group;
            map_group = [
              {
                local = "users";
                "with" = "${cfg-client-posix-group-prefix}users${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
              {
                local = "libvirtd";
                "with" = "${cfg-client-posix-group-prefix}libvirtd${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
              {
                local = "networkmanager";
                "with" =
                  "${cfg-client-posix-group-prefix}networkmanager${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
              {
                local = "gamemode";
                "with" = "${cfg-client-posix-group-prefix}gamemode${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
              {
                local = "wheel";
                "with" = "${cfg-client-posix-group-prefix}wheel${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
              {
                local = "podman";
                "with" = "${cfg-client-posix-group-prefix}podman${cfg-client-posix-group-suffix}@${cfg-domain}";
              }
            ];
          };
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
