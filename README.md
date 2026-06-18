# inputs-cache

A [flake-parts](https://flake.parts) module that turns a flake's **transitive
input closure** into a derivation. By default this derivation will be added to the flakes check attribute. Building the check realizes every input
source tree into the store:

- The inputs can now be properly substituted from a cache. Meaning unnecessary API requests are avoided.
- We get the benefit of possibly faster input fetching, depending on the substituter.
- It fails fast in CI.
- The check is a real derivation, so we get all the benefits the Nix store gives us.

The result is a single `linkFarm` of the deduplicated input source trees:
we

```shell-session
$ nix build .#checks.x86_64-linux.inputs && ls result/
crane-j33zbqdl  flake-parts-ch5n4xdd  nixpkgs-3a2vdn5i  nixpkgs-lib-r7kxix1d [...]
```

It does not *provide* a cache, it allows caching of flake inputs.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    inputs-cache.url = "github:a-kenji/inputs-cache";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [ inputs.inputs-cache.flakeModule ];
    };
}
```

Add it to your flake's inputs:

```shell-session
nix run nixpkgs#flake-edit add inputs-cache github:a-kenji/inputs-cache
```

Build the check, then the inputs will be substitutable from the store, or a cache.

```shell-session
nix build .#checks.x86_64-linux.inputs
```

## Without flake-parts

We also provide a NixOS module.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    inputs-cache.url = "github:a-kenji/inputs-cache";
  };

  outputs =
    { nixpkgs, inputs-cache, ... }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      checks.x86_64-linux.inputs = inputs-cache.lib.mkInputsCheck {
        inherit pkgs inputs;
      };
    };
}
```

`mkInputsCheck` takes:

| Argument     | Default    | Description |
| ------------ | ---------- | ----------- |
| `pkgs`       | (required) | The nixpkgs instance for the target system
| `inputs`     | (required) | Your flake's whole `inputs` attrset

As well as the options of the `flake-parts` module.

## Options

All options live under the `inputs-cache` namespace.

| Option       | Type            | Default    | Description |
| ------------ | --------------- | ---------- | ----------- |
| `enable`     | bool            | `true`     | Generate the check at all. |
| `transitive` | bool            | `true`     | Realize inputs of inputs |
| `exclude`    | list of string  | `[ ]`      | Top-level input names to skip (and their transitive inputs) |
| `checkName`  | string          | `"inputs"` | Name of the generated `checks.<system>.<name>` attribute. |

## How it works

`builtins.genericClosure`, for each input's store `outPath`, walks the
resolved `inputs` graph.
`flake = false` inputs are treated as leaves.
Entries are named `[checkName]-[hex of store hash]`.

## Inspiration

Inspired by [`hestia`](https://github.com/Mic92/hestia).

## Licence

MIT
