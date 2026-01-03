# dot-nix-shared

A collection of shared nix home-manager modules that can be imported by different home manager flakes in various contexts.

## Overview

This repository provides reusable home-manager modules for common configurations including:
- **Git**: Git configuration with sensible defaults
- **Shell**: Shell configuration (bash/zsh) with common aliases
- **Development**: Common development tools and utilities

## Usage

### Adding as a Flake Input

Add this repository as an input to your flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dot-nix-shared = {
      url = "github:weltenwort/dot-nix-shared";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, dot-nix-shared, ... }: {
    # Your home-manager configuration
  };
}
```

### Importing Modules

You can import individual modules or all modules at once:

#### Import All Modules (Default)

```nix
home-manager.lib.homeManagerConfiguration {
  modules = [
    dot-nix-shared.homeManagerModules.default
    # Your other modules
  ];
}
```

#### Import Individual Modules

```nix
home-manager.lib.homeManagerConfiguration {
  modules = [
    dot-nix-shared.homeManagerModules.git
    dot-nix-shared.homeManagerModules.shell
    dot-nix-shared.homeManagerModules.development
    # Your other modules
  ];
}
```

## Available Modules

### Git Module

Provides shared git configuration with sensible defaults.

```nix
{
  programs.git.shared = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    defaultBranch = "main";  # optional, defaults to "main"
  };
}
```

Features:
- Configurable user name and email
- Default branch configuration
- Pull with rebase enabled
- Color UI enabled
- Common ignore patterns (.DS_Store, editor files, etc.)

### Shell Module

Provides shared shell configuration for bash and zsh.

```nix
{
  programs.shell.shared = {
    enable = true;
    enableBashIntegration = true;   # optional, defaults to true
    enableZshIntegration = true;    # optional, defaults to true
    aliases = {
      # Add your custom aliases
      gs = "git status";
      gc = "git commit";
    };
  };
}
```

Features:
- Common shell aliases (ll, la, .., ...)
- Bash with completion and history control
- Zsh with completion, autosuggestion, and syntax highlighting
- Custom alias support

### Development Module

Provides common development tools.

```nix
{
  programs.development.shared = {
    enable = true;
    enableCommonTools = true;  # optional, defaults to true
    tools = with pkgs; [
      # Add your additional tools
      nodejs
      python3
    ];
  };
}
```

Features:
- Common tools: curl, wget, jq, tree
- Extensible with additional tools

## Example Configuration

Here's a complete example of using these modules:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dot-nix-shared = {
      url = "github:weltenwort/dot-nix-shared";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, dot-nix-shared, ... }: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        dot-nix-shared.homeManagerModules.default
        {
          programs.git.shared = {
            enable = true;
            userName = "John Doe";
            userEmail = "john@example.com";
          };

          programs.shell.shared = {
            enable = true;
            aliases = {
              gs = "git status";
              gp = "git push";
            };
          };

          programs.development.shared = {
            enable = true;
            tools = with pkgs; [
              nodejs
              python3
            ];
          };

          home.stateVersion = "23.11";
        }
      ];
    };
  };
}
```

## Contributing

Contributions are welcome! Feel free to open issues or pull requests.

## License

This project is open source and available under the MIT License.