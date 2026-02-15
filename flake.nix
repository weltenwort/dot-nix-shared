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
      homeModules = {
        git = import ./home-manager-modules/git.nix;
        shell = import ./home-manager-modules/shell.nix;
        tmux = import ./home-manager-modules/tmux.nix;
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
