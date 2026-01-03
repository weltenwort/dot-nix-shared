{
  description = "Example home-manager configuration using dot-nix-shared";

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

  outputs = { self, nixpkgs, home-manager, dot-nix-shared, ... }: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        # Example configuration for a user named "john" on host "laptop"
        "john@laptop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            # Import all shared modules
            dot-nix-shared.homeManagerModules.default

            # Your configuration
            {
              # Enable and configure git
              programs.git.shared = {
                enable = true;
                userName = "John Doe";
                userEmail = "john@example.com";
                defaultBranch = "main";
              };

              # Enable and configure shell
              programs.shell.shared = {
                enable = true;
                enableBashIntegration = true;
                enableZshIntegration = true;
                aliases = {
                  gs = "git status";
                  gd = "git diff";
                  gc = "git commit";
                  gp = "git push";
                  gl = "git log --oneline --graph";
                };
              };

              # Enable development tools
              programs.development.shared = {
                enable = true;
                enableCommonTools = true;
                tools = with pkgs; [
                  nodejs
                  python3
                  rustc
                  cargo
                ];
              };

              # Home Manager needs to know where to find your home directory
              home = {
                username = "john";
                homeDirectory = "/home/john";
                stateVersion = "23.11";
              };

              # Let Home Manager install and manage itself
              programs.home-manager.enable = true;
            }
          ];
        };

        # Alternative example: selective module import
        "jane@desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            # Import only specific modules
            dot-nix-shared.homeManagerModules.git
            dot-nix-shared.homeManagerModules.shell

            {
              programs.git.shared = {
                enable = true;
                userName = "Jane Smith";
                userEmail = "jane@example.com";
              };

              programs.shell.shared = {
                enable = true;
                enableZshIntegration = true;
                enableBashIntegration = false;
              };

              home = {
                username = "jane";
                homeDirectory = "/home/jane";
                stateVersion = "23.11";
              };

              programs.home-manager.enable = true;
            }
          ];
        };
      };
    };
}
