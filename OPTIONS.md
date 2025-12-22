<!-- markdownlint-disable MD013 -->

# Option reference

This file contains all options available in the NixOS-Blocks repo.

| Name                                                        | Type            | Description                                       |
| ----------------------------------------------------------- | --------------- | ------------------------------------------------- |
| `nixos-blocks.kanidm.options.server.enable`                 | boolean         | Enable the KanIDM server                          |
| `nixos-blocks.kanidm.options.server.role`                   | enum            | Sets the server role                              |
| `nixos-blocks.kanidm.options.client.enable`                 | boolean         | Enable the KanIDM client                          |
| `nixos-blocks.kanidm.options.client.posix-groups`           | list of strings | Define which groups are allowed to log-in         |
| `nixos-blocks.kanidm.options.client.posix-group-prefix`     | string          | Define the posix group prefix if you have one     |
| `nixos-blocks.kanidm.options.client.posix-group-suffix`     | string          | Define the posix group suffix if you have one     |
| `nixos-blocks.kanidm.options.client.local-account-override` | list of strings | List of local accounts that KanIDM may override   |
| `nixos-blocks.kanidm.options.domain.top-level`              | string          | Top-level domain for the KanIDM instance          |
| `nixos-blocks.kanidm.options.package`                       | package         | KanIDM package                                    |
