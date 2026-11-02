# Flake providing the [eezo](https://eezo.io) CLI

I made this to scratch my own itch, that is to install the eezo CLI in a Nix-managed fashion.

Eezo requires JDK 25.

## Example usage in your project flake

Add sbt, override to inject JDK 25.
If you use [fly.io](https://fly.io) for deployments (`eezo deploy`) add `flyctl`.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    eezo = {
      url = "github:what-the-functor/nix-eezo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, eezo, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {

          default = pkgs.mkShell {
            packages = [
              eezo.packages.${system}.eezo
              (pkgs.sbt.override { jre = pkgs.jdk25; })
              pkgs.flyctl
            ];
          };

        });
    };
}
```

The package does not bundle `sbt`, the dev shell has to provide it as above.

