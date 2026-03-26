{
  description = "Shared nix configuration modules for home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    dot-nix-vim = {
      url = "git+ssh://git@github.com/weltenwort/dot-nix-vim.git?ref=nixcats";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ ... }:
    {
      darwinModules = {
        base = import ./darwin-modules/base.nix;
      };

      homeModules = {
        git = import ./home-manager-modules/git.nix;
        lima = import ./home-manager-modules/lima.nix;
        nix = import ./home-manager-modules/nix.nix;
        opencode = import ./home-manager-modules/opencode.nix;
        shell = import ./home-manager-modules/shell.nix;
        ssh = import ./home-manager-modules/ssh.nix;
        nvim =
          { ... }:
          {
            imports = [
              inputs.dot-nix-vim.homeModule
              (import ./home-manager-modules/nvim.nix)
            ];
          };
      };
    };
}
