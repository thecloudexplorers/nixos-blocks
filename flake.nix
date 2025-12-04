{
  description = "NixOS Blocks module";

  outputs =
    { self, ... }:
    let
      # Import private inputs (for development)
      privateInputs =
        (import {
          src = ./tests;
        }).defaultNix;

      systems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];

      formatSystems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # Helper to iterate over systems
      eachSystem =
        f:
        privateInputs.nixos-unstable-small.lib.genAttrs systems (
          system: f privateInputs.nixos-unstable-small.legacyPackages.${system} system
        );

      eachSystemFormat =
        f:
        privateInputs.nixos-unstable-small.lib.genAttrs formatSystems (
          system: f privateInputs.nixos-unstable-small.legacyPackages.${system} system
        );
    in
    {

      nixosModules =
        let
          deprecated =
            issue: name: value:
            builtins.trace "warning: ${name} flake output is deprecated and will be removed. See https://github.com/NixOS/nixos-hardware/issues/${issue} for more information" value;
          import = path: path; # let the module system know what we are exporting
        in
        {
          kanidm = import ./blocks/kanidm;
          # Deprecated example
          # dell-e7240 = deprecated "1326" "dell-e7240" (import ./dell/e7240);
        };

      # Add formatter for `nix fmt`
      formatter = eachSystemFormat (
        pkgs: _system:
        (privateInputs.treefmt-nix.lib.evalModule pkgs ./tests/treefmt.nix).config.build.wrapper
      );

      # Add packages
      packages = eachSystem (
        pkgs: system: {
          run-tests = pkgs.callPackage ./tests/run-tests.nix {
            inherit self;
          };
        }
      );

      # Add checks for `nix run .#run-tests`
      checks = eachSystem (
        pkgs: system:
        let
          treefmtEval = privateInputs.treefmt-nix.lib.evalModule pkgs ./tests/treefmt.nix;
          nixosTests = import ./tests/nixos-tests.nix {
            inherit
              self
              privateInputs
              system
              pkgs
              ;
          };
        in
        pkgs.lib.optionalAttrs (self.formatter ? ${system}) {
          formatting = treefmtEval.config.build.check self;
        }
        // nixosTests
      );
    };
}
