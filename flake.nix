{
  description = "NixOS Blocks module";

  outputs = {
    nixosModules.kanidm = blocks/kanidm/default.nix;
  };
}
