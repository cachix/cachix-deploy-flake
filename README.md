Functions to help manage Cachix Deploy when using flakes.

See https://docs.cachix.org/deploy/deploying-to-agents for more.

# Reference

- `lib`: takes `pkgs` and returns the rest of the functions
- `lib.spec`: takes attribute set of all options described in https://docs.cachix.org/deploy/reference
- `lib.nixos` takes a module and returns nixos derivation
- `lib.darwin` takes a module and returns nix-darwin derivation
- `lib.homeManager` takes attribute set of options and returns home-manager
- `lib.bootstrapNixOS` documented in https://github.com/cachix/cachix-deploy-hetzner-dedicacted