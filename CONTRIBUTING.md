# Contributing

## Updating eezo

1. Bump `version` in `package.nix`.
2. Set the `src` and `pom` hashes to `lib.fakeHash`.
3. Run `nix build` and copy the real hashes in from the errors.
4. If `patches/upgrade-nix.patch` no longer applies to the new `bin/eezo`, refresh it.
5. Run `nix flake check --all-systems`.

## Releasing

Tags match the packaged eezo version: `v0.3.0` packages eezo 0.3.0.

Packaging-only fixes normally wait on `main` for the next eezo release. If one cannot wait, tag it
with semver build metadata, `v0.3.0+nix.2`: the same eezo version, packaged again.
