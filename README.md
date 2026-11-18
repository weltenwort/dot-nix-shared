# dot-nix-shared

Shared nix modules used across multiple configuration repos. Includes platform-agnostic home-manager modules and platform-specific darwin system modules.

## Exported `darwinModules`

This flake exposes via `darwinModules`:

| Module | Description | Key options |
|--------|-------------|-------------|
| `base` | darwin system baseline: user account, nix settings (incl. `cache.numtide.com` substituter), fish, homebrew, key remapping | `custom.darwin.mainUser` (required) |

### Usage

Add `inputs.dot-nix-shared.darwinModules.base` to your `darwinSystem` modules list, then set the required option in an accompanying inline module:

```nix
nix-darwin.lib.darwinSystem {
  modules = [
    inputs.dot-nix-shared.darwinModules.base
    { custom.darwin.mainUser = "alice"; }
    { system.configurationRevision = self.rev or self.dirtyRev or null; }
    # host-specific overrides ...
  ];
}
```

> `system.configurationRevision` must be set in the consumer flake because it references the consumer's `self`.

## Exported `homeModules`

This flake exposes via `homeModules`:

| Module | Description | Key programs |
|--------|-------------|--------------|
| `claude-code` | Claude Code AI coding assistant | `claude-code`, `skills` (from llm-agents.nix) |
| `devenv` | devenv with fish hook | `devenv` |
| `git` | Git, delta, gh, gitui, shell aliases | Configurable via `custom.git.userEmail` / `custom.git.userName` options |
| `herdr` | Herdr terminal workspace manager | `herdr` (from llm-agents.nix) |
| `lima` | Lima VM manager | `lima` |
| `nix` | Nix tooling | `nh` (Nix helper), `nix-flake-update-hydra` (wraps `nix flake update`, pinning nixpkgs inputs to the latest revision built by hydra) |
| `opencode` | OpenCode AI coding assistant | `opencode`, `skills`, `nono` (from llm-agents.nix) |
| `paseo` | Paseo agent orchestration CLI and daemon | `paseo`, `paseo-server` (from llm-agents.nix, wrapped with nodejs/npm on their PATH for plugin builds) |
| `python` | Python interpreter and tooling | `python3`, `uv`, `pipx` |
| `shell` | Fish, eza, starship, fzf, bat, ripgrep, fd, direnv, nix-your-shell | Sets `EDITOR=nvim`, `PAGER=bat` (via `mkDefault`) |
| `ssh` | Base SSH config | `enableDefaultConfig=false`, includes for terraform and Lima SSH configs, `addKeysToAgent=yes` |
| `tmux` | Tmux with onedark theme, vi keybindings, plugins | copycat, pain-control, tmux-fzf, vim-tmux-navigator, sysstat, yank, open |
| `nvim` | Neovim config via dot-nix-vim | `dot-nix-shared` owns and imports `dot-nix-vim.homeModule` internally |

## Exported `packages`

| Package | Description |
|---------|-------------|
| `paseo` | The wrapped paseo installed by `homeModules.paseo` (only on systems llm-agents.nix supports: `aarch64-darwin`, `aarch64-linux`, `x86_64-linux`). Try it with `nix run .#paseo -- --version`. |

### paseo and npm

paseo's daemon builds npm plugins by running the plugin manifest's `build` commands (e.g. `npm ci`) with `npm` taken from its own PATH. The llm-agents.nix package exposes no npm, so plugin installs fail with `spawn npm ENOENT`. `packages/paseo.nix` wraps `paseo` and `paseo-server` with the package's own nodejs (`paseo.nodejs`, currently 22.x) prefixed to PATH; the daemon inherits the CLI's environment, so it gets npm too, while node/npm stay out of other shells.

A daemon that was started by an unwrapped paseo keeps its old environment. After switching, run `paseo daemon stop` and start it again from the wrapped CLI (`paseo daemon restart` reuses the old supervisor launch).

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

### AI tooling from llm-agents.nix

The `claude-code`, `opencode`, `herdr` and `paseo` modules install their packages from [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix), which tracks upstream releases much faster than nixpkgs. The `llm-agents` input is owned by this flake and deliberately does **not** follow `nixpkgs`, so its prebuilt binaries can be fetched from `https://cache.numtide.com`.

To get cache hits, the consuming machine's nix config must trust that cache (flake `nixConfig` is not inherited from inputs). `darwinModules.base` sets this up on macOS; on Linux add it to `/etc/nix/nix.conf`:

```
extra-substituters = https://cache.numtide.com
extra-trusted-public-keys = niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
```

## Configurable Options

### `custom.darwin.mainUser`

- **Type:** `str`
- **Default:** *(required — no default)*
- **Description:** The main user account name for the darwin system. Used to configure `users.knownUsers`, `users.users.<name>`, and `system.primaryUser`.

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

**Home-manager module (platform-agnostic):**
1. Create `home-manager-modules/<name>.nix` as a standard home-manager module.
2. Add it to the `homeModules` attrset in `flake.nix`.
3. Keep it platform-agnostic — no `stdenv.isDarwin`/`isLinux` guards. Platform-specific config belongs in consumer repos.
4. Use `lib.mkDefault` for values consumers may want to override.
5. Use `lib.mkOption` for user-facing settings (see `git.nix` for the pattern).

**Darwin system module:**
1. Create `darwin-modules/<name>.nix` as a standard nix-darwin module.
2. Add it to the `darwinModules` attrset in `flake.nix`.
3. Darwin-specific options and packages are fine here.
4. Use `lib.mkDefault` for host-overridable values (e.g. `system.stateVersion`, `nixpkgs.hostPlatform`).
5. Use `lib.mkOption` for consumer-facing settings (see `custom.darwin.mainUser` in `base.nix` for the pattern).
