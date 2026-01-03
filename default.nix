# Backwards compatibility for non-flake nix
# This provides access to the modules for legacy nix commands

{
  # Export the modules for use in non-flake configurations
  modules = {
    git = import ./modules/git;
    shell = import ./modules/shell;
    development = import ./modules/development;
    default = import ./modules/default.nix;
  };
}
