Functions to help manage Cachix Deploy when using flakes.

See https://docs.cachix.org/deploy/deploying-to-agents for more.

# Reference

- `lib`: takes `pkgs` and returns the rest of the functions
- `json`: takes attribute set of all options described in https://docs.cachix.org/deploy/reference
- `nixos` takes a module and returns nixos derivation
- `darwin` takes a module and returns nix-darwin derivation
