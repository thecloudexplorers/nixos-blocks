# KanIDM Identity Provider

## Usage

One can use the `kanidm-block` options as follows:

``` nix
kanidm-block.options.domain.top-level = "domain.tld";
kanidm-block.options.package = pkgs.kanidm_1_8;
kanidm-block.options.role = "WriteReplica";
```

This will spin up an KanIDM instance that is accesible on https://login.domain.tld with alternative names for:

- `login.domain.tld`
- `auth.domain.tld`
- `idm.domain.tld`

## Requirements

### ACME
To use this module, the generic settings for ACME need to be specified seprately for the certificate request to work. Example:

``` nix
security.acme = {
  acceptTerms = true;
  maxConcurrentRenewals = 10;
  defaults.email = "user@domain.tld";
  defaults.dnsProvider = "provider";
  defaults.dnsPropagationCheck = true;
  defaults.dnsResolver = "127.0.0.1:53";
  defaults.environmentFile = "/path/to/keyfile";
};
```

### Database mounted on external filesystem
To place the kanidm database on an external volume, you can mount `/var/lib/kanidm` on an external mountpoint. NFS example:

``` nix
fileSystems."/var/lib/kanidm" = {
  device = "0.0.0.0:/appdata/kanidm";
  fsType = "nfs";
  options = [ "nfsvers=4.2" "nolock" "soft" "rw" ];
};
```
