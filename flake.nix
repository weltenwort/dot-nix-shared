{
  description = "Shared nix configuration modules for home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        darwinModules = {
          base = import ./darwin-modules/base.nix;
        };

        homeModules = {
          claude-code = import ./home-manager-modules/claude-code.nix;
          devenv = import ./home-manager-modules/devenv.nix;
          git = import ./home-manager-modules/git.nix;
          lima = import ./home-manager-modules/lima.nix;
          nix = import ./home-manager-modules/nix.nix;
          opencode = import ./home-manager-modules/opencode.nix;
          python = import ./home-manager-modules/python.nix;
          shell = import ./home-manager-modules/shell.nix;
          ssh = import ./home-manager-modules/ssh.nix;
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = [
              # pkgs.mcp-nixos
              pkgs.nil
              pkgs.nixfmt
            ];
          };
        };
      }
    );
}
