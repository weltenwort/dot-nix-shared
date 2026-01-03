# Example Configurations

This directory contains example configurations demonstrating how to use the shared nix home-manager modules.

## Files

- `flake.nix` - Example flake showing multiple ways to use the shared modules

## Usage

These examples are for reference only. To use them:

1. Copy the relevant parts to your own home-manager configuration
2. Adjust usernames, email addresses, and other personal settings
3. Add or remove tools and configurations as needed

## Example 1: Using All Modules

The first configuration (`john@laptop`) demonstrates importing all shared modules using the default module:

```nix
modules = [
  dot-nix-shared.homeManagerModules.default
  { /* your configuration */ }
];
```

This imports git, shell, and development modules all at once.

## Example 2: Selective Module Import

The second configuration (`jane@desktop`) demonstrates importing only specific modules:

```nix
modules = [
  dot-nix-shared.homeManagerModules.git
  dot-nix-shared.homeManagerModules.shell
  { /* your configuration */ }
];
```

This gives you more control over which modules are included.

## Building the Examples

To test these examples (requires nix with flakes enabled):

```bash
# Build the first example
nix build .#homeConfigurations."john@laptop".activationPackage

# Build the second example
nix build .#homeConfigurations."jane@desktop".activationPackage
```

## Activating a Configuration

After building, you can activate a home-manager configuration:

```bash
./result/activate
```

Note: These examples are not meant to be used directly in production. They serve as templates for your own configurations.
