# dot-nix-shared

Shared nix home-manager modules used across multiple configuration repos. These modules are platform-agnostic and contain only configuration that is common to all environments.

## Exported `homeModules`

This flake exposes via `homeModules`:

| Module | Description | Key programs |
|--------|-------------|--------------|
| `git` | Git, delta, gh, gitui, shell aliases | Configurable via `custom.git.userEmail` / `custom.git.userName` options |
| `lima` | Lima VM manager | `lima` |
| `nix` | Nix tooling | `nh` (Nix helper) |
| `opencode` | OpenCode AI coding assistant | `opencode` |
| `shell` | Fish, eza, starship, fzf, bat, ripgrep, fd, direnv, nix-your-shell | Sets `EDITOR=nvim`, `PAGER=bat` (via `mkDefault`) |
| `ssh` | Base SSH config | `enableDefaultConfig=false`, includes for terraform and Lima SSH configs, `addKeysToAgent=yes` |
| `tmux` | Tmux with onedark theme, vi keybindings, plugins | copycat, pain-control, tmux-fzf, vim-tmux-navigator, sysstat, yank, open |
| `nvim` | Neovim config via dot-nix-vim | `dot-nix-shared` owns and imports `dot-nix-vim.homeModule` internally |

## Usage

Add as a flake input in a consumer repo:

```nix
inputs.dot-nix-shared = {
  url = "git+ssh://git@github.com/weltenwort/dot-nix-shared.git";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then import modules in a home-manager configuration:

```nix
{ inputs, ... }:
{
  imports = [
    inputs.dot-nix-shared.homeModules.git
    inputs.dot-nix-shared.homeModules.shell
    inputs.dot-nix-shared.homeModules.tmux
    inputs.dot-nix-shared.homeModules.nvim
  ];

  # Override defaults
  custom.git.userEmail = "you@example.com";
}
```

Consumers do not need to declare `dot-nix-vim`; the dependency is fully owned and pinned by `dot-nix-shared`.

## Configurable Options

### `custom.git.userEmail`

- **Type:** `str`
- **Default:** `"weltenwort@users.noreply.github.com"`

### `custom.git.userName`

- **Type:** `str`
- **Default:** `"Felix Stürmer"`

## Consumer Repos

| Repo | Purpose |
|------|---------|
| [dot-nix-darwin](https://github.com/weltenwort/dot-nix-darwin) | nix-darwin configs for macOS hosts |
| [nix-home-elastic](https://github.com/weltenwort/nix-home-elastic) | home-manager configs for work dev VMs |
| [dot-nix-dev](https://github.com/weltenwort/dot-nix-dev) | home-manager configs for personal dev VMs |

## Adding a New Shared Module

1. Create `home-manager-modules/<name>.nix` as a standard home-manager module.
2. Add it to the `homeModules` attrset in `flake.nix`.
3. Keep it platform-agnostic — no `stdenv.isDarwin`/`isLinux` guards. Platform-specific config belongs in consumer repos.
4. Use `lib.mkDefault` for values consumers may want to override.
5. Use `lib.mkOption` for user-facing settings (see `git.nix` for the pattern).
