# AGENTS.md

## Repository Role

This is the **shared module library** in a multi-repo nix configuration setup. It provides platform-agnostic home-manager modules consumed by three downstream repos:

- `dot-nix-darwin` — macOS nix-darwin system configurations
- `nix-home-elastic` — home-manager configurations for work dev VMs
- `dot-nix-dev` — home-manager configurations for personal dev VMs

## Architecture

```
dot-nix-shared (this repo)
  └── homeModules.{git, shell, tmux, nvim}
        ├── consumed by dot-nix-darwin   (macOS, adds brew/kitty/vifm)
        ├── consumed by nix-home-elastic (Linux, adds fish plugins/btop/work tools)
        └── consumed by dot-nix-dev      (Linux, minimal personal setup)
```

## Key Conventions

- **Platform-agnostic only.** Never use `stdenv.isDarwin` / `isLinux` guards here. Platform-specific config belongs in consumer repos.
- **Use `lib.mkDefault`** for values consumers commonly override (e.g. session variables).
- **Use `lib.mkOption`** for user-facing settings (see `custom.git.userEmail` in `git.nix`).
- **One concern per module.** `git.nix` = git tools, `shell.nix` = shell environment, `tmux.nix` = tmux, `nvim.nix` = neovim.
- **The shared flake owns the `dot-nix-vim` dependency.** `homeModules.nvim` imports `dot-nix-vim.homeModule` internally; consumer repos only import `dot-nix-shared.homeModules.nvim`.

## File Layout

```
flake.nix                              # Exposes homeModules attrset
home-manager-modules/
  git.nix                              # Git, delta, gh, gitui, aliases
  shell.nix                            # Fish, eza, starship, fzf, bat, ripgrep, fd, direnv
  tmux.nix                             # Tmux with onedark theme and plugins
  nvim.nix                             # dot-nix-vim option configuration
.github/workflows/
  notify-consumers.yml                 # Dispatches update events to consumer repos
```

## Adding a New Module

1. Create `home-manager-modules/<name>.nix` as a standard NixOS/home-manager module.
2. Register it in `flake.nix` under `homeModules.<name>`.
3. Keep it platform-agnostic.
4. Update this file and `README.md` to document the new module.

## CI

- `notify-consumers.yml` runs on push to `main` and sends `repository_dispatch` events to all consumer repos.
- Requires `CONSUMER_DISPATCH_TOKEN` secret (GitHub PAT with `repo` scope).
