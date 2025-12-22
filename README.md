# nixos-blocks

These are opinionated general purpose blocks designed to simplifiy deployment
of services.

## Usage

To use these blocks you need to add it to the inputs and outputs of your flake:

```nix
{
  inputs = {
    nixos-blocks.url = "github:thecloudexplorers/nixos-blocks";
  };
  outputs = {
    nixos-blocks,
    ...
  }:
```

Then, you can use the options defined in each block
(see README.md in each block folder for definitions)
in your flake or configuration.nix files:

``` nix
example-block.options.domain = "domain.tld";
example-block.options.package = pkgs.package;
example-block.options.string = "foo";
```

## Naming of options

The naming convention is as follows:

A block always needs an enable option like so:

``` nix
nixos-blocks.<block-name>.enable = true;
```

Next the options can be defined like:

``` nix
nixos-blocks.<block-name>.options.<option-name> = "option";
```

All options are referenced in [OPTIONS.md](OPTIONS.md).
