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
- **The shared flake owns the `llm-agents` (numtide/llm-agents.nix) dependency.** Fast-moving AI tools (claude-code, opencode, herdr, skills, nono, paseo) come from it instead of nixpkgs. Modules that need it are written as `{ inputs }: { pkgs, ... }: { ... }` and wired in `flake.nix` via `import ./home-manager-modules/<name>.nix { inherit inputs; }`. The input intentionally does not follow `nixpkgs` so binaries from `cache.numtide.com` are usable.
- **opencode is OpenCode 2.** llm-agents.nix's `opencode` is still 1.x; 2.x is the separate `opencode2` package with a `bin/opencode2` binary. `packages/opencode.nix` adds a `bin/opencode` symlink and keeps an `opencode-<version>` name/`mainProgram = "opencode"`, so the command name stays `opencode` and home-manager's `programs.opencode` writes the 2.x config format (it switches on the package version). Do not go back to `llmPkgs.opencode` without meaning to downgrade to 1.x.
- **paseo is installed wrapped.** `packages/paseo.nix` prefixes PATH of `paseo`/`paseo-server` with the package's own `paseo.nodejs` so the daemon can run plugin `npm` builds. After switching from an unwrapped paseo, a running daemon must be stopped (`paseo daemon stop`) and started from the wrapped CLI; `paseo daemon restart` keeps the old environment.

## File Layout

```
flake.nix                              # Exposes darwinModules, homeModules and packages (opencode, paseo) attrsets
darwin-modules/
  base.nix                             # darwin system baseline: user account, nix settings (incl. numtide cache), homebrew, key remapping
home-manager-modules/
  claude-code.nix                      # Claude Code + skills (llm-agents.nix)
  devenv.nix                           # devenv with fish hook
  git.nix                              # Git, delta, gh, gitui, aliases
  herdr.nix                            # Herdr (llm-agents.nix)
  lima.nix                             # Lima VM manager
  nix.nix                              # Nix tooling (nh, nix-flake-update-hydra wrapper)
  nix-flake-update-hydra.sh            # Script backing nix-flake-update-hydra: `nix flake update` with nixpkgs inputs pinned to latest hydra-built channel revision
  opencode.nix                         # OpenCode 2 + skills + nono (llm-agents.nix), installs packages/opencode.nix
  paseo.nix                            # Paseo agent orchestration CLI/daemon (llm-agents.nix), installs packages/paseo.nix
  python.nix                           # Python interpreter, uv, pipx
  shell.nix                            # Fish, eza, starship, fzf, bat, ripgrep, fd, direnv
  ssh.nix                              # Base SSH config (enableDefaultConfig=false, lima/terraform includes)
  tmux.nix                             # Tmux with onedark theme and plugins
  nvim.nix                             # dot-nix-vim option configuration
packages/
  opencode.nix                         # llm-agents.nix `opencode2` (OpenCode 2.x) with a `bin/opencode` symlink; also exported as packages.<system>.opencode
  paseo.nix                            # paseo wrapped with its own nodejs on PATH so the daemon finds npm for plugin builds (avoids `spawn npm ENOENT`); also exported as packages.<system>.paseo
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
