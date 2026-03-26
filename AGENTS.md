# AGENTS.md

## Repository Role

This is the **shared module library** in a multi-repo nix configuration setup. It provides platform-agnostic home-manager modules consumed by three downstream repos:

- `dot-nix-darwin` — macOS nix-darwin system configurations
- `nix-home-elastic` — home-manager configurations for work dev VMs
- `dot-nix-dev` — home-manager configurations for personal dev VMs

## Architecture

```
dot-nix-shared (this repo)
  ├── darwinModules.{base}
  │     └── consumed by dot-nix-darwin   (macOS system config)
  └── homeModules.{git, shell, tmux, nvim, ...}
        ├── consumed by dot-nix-darwin   (macOS, adds brew/kitty/vifm)
        ├── consumed by nix-home-elastic (Linux, adds fish plugins/btop/work tools)
        └── consumed by dot-nix-dev      (Linux, minimal personal setup)
```

## Key Conventions

- **`homeModules` are platform-agnostic.** Never use `stdenv.isDarwin` / `isLinux` guards inside `home-manager-modules/`. Platform-specific home-manager config belongs in consumer repos.
- **`darwinModules` are explicitly darwin-specific.** Modules in `darwin-modules/` target nix-darwin system configuration; they may freely use darwin-only options and packages.
- **Use `lib.mkDefault`** for values consumers commonly override (e.g. session variables, `system.stateVersion`, `nixpkgs.hostPlatform`).
- **Use `lib.mkOption`** for user-facing settings (see `custom.git.userEmail` in `git.nix`, `custom.darwin.mainUser` in `darwin-modules/base.nix`).
- **One concern per module.** `git.nix` = git tools, `shell.nix` = shell environment, `tmux.nix` = tmux, `nvim.nix` = neovim, `darwin-modules/base.nix` = darwin system baseline.
- **The shared flake owns the `dot-nix-vim` dependency.** `homeModules.nvim` imports `dot-nix-vim.homeModule` internally; consumer repos only import `dot-nix-shared.homeModules.nvim`.

## File Layout

```
flake.nix                              # Exposes darwinModules and homeModules attrsets
darwin-modules/
  base.nix                             # darwin system baseline: user account, nix settings, homebrew, key remapping
home-manager-modules/
  git.nix                              # Git, delta, gh, gitui, aliases
  lima.nix                             # Lima VM manager
  nix.nix                              # Nix tooling (nh)
  opencode.nix                         # OpenCode AI coding assistant
  shell.nix                            # Fish, eza, starship, fzf, bat, ripgrep, fd, direnv
  ssh.nix                              # Base SSH config (enableDefaultConfig=false, lima/terraform includes)
  tmux.nix                             # Tmux with onedark theme and plugins
  nvim.nix                             # dot-nix-vim option configuration
```

## Adding a New Module

**Home-manager module (platform-agnostic):**
1. Create `home-manager-modules/<name>.nix` as a standard home-manager module.
2. Register it in `flake.nix` under `homeModules.<name>`.
3. Keep it platform-agnostic — no `stdenv.isDarwin` / `isLinux` guards.
4. Update this file and `README.md` to document the new module.

**Darwin system module:**
1. Create `darwin-modules/<name>.nix` as a standard nix-darwin module.
2. Register it in `flake.nix` under `darwinModules.<name>`.
3. Darwin-specific options and packages are fine here.
4. Update this file and `README.md` to document the new module.

## Documentation Maintenance

- Keep `README.md` and `AGENTS.md` in sync with the current repository state.
- When changing behavior, defaults, module exports, file layout, or setup workflows, update both docs in the same change.
- Before finalizing edits, verify examples and referenced modules against real files (`flake.nix`, `home-manager-modules/*`) to avoid stale documentation.
