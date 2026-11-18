{
  description = "Shared nix configuration modules for home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
  };

  # Fast-moving AI coding tools. Intentionally does not follow our nixpkgs so
  # that the prebuilt binaries from cache.numtide.com can be used.
  inputs.llm-agents = {
    url = "github:numtide/llm-agents.nix";
  };

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  outputs =
    { nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Only for systems llm-agents.nix builds paseo for.
          packages = nixpkgs.lib.optionalAttrs (inputs.llm-agents.packages ? ${system}) {
            paseo = import ./packages/paseo.nix {
              inherit pkgs;
              inherit (inputs.llm-agents.packages.${system}) paseo;
            };
          };

          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                pkgs.mcp-nixos
                pkgs.nil
                pkgs.nixfmt
              ];
            };
          };
        }
      ) // {

      darwinModules = {
        base = import ./darwin-modules/base.nix;
      };

      homeModules = {
        claude-code = import ./home-manager-modules/claude-code.nix { inherit inputs; };
        devenv = import ./home-manager-modules/devenv.nix;
        git = import ./home-manager-modules/git.nix;
        herdr = import ./home-manager-modules/herdr.nix { inherit inputs; };
        lima = import ./home-manager-modules/lima.nix;
        nix = import ./home-manager-modules/nix.nix;
        opencode = import ./home-manager-modules/opencode.nix { inherit inputs; };
        paseo = import ./home-manager-modules/paseo.nix { inherit inputs; };
        python = import ./home-manager-modules/python.nix;
        shell = import ./home-manager-modules/shell.nix;
        ssh = import ./home-manager-modules/ssh.nix;
      };

    };
}
