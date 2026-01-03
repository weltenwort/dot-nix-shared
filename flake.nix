{
  description = "A collection of shared nix home-manager modules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    # Home Manager modules that can be imported
    homeManagerModules = {
      # Git configuration module
      git = import ./modules/git;
      
      # Shell configuration module
      shell = import ./modules/shell;
      
      # Development tools module
      development = import ./modules/development;
      
      # Default module that includes common configurations
      default = import ./modules/default.nix;
    };

    # Convenience attribute for importing all modules
    homeManagerModule = self.homeManagerModules.default;
  };
}
