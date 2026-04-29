# This module sets dot-nix-vim options.
# The import of `dot-nix-vim.homeModule` is owned by `dot-nix-shared` flake outputs.
{ inputs, ... }:
{
  home.packages = [
    inputs.dot-nix-vim
  ];

  # dot-nix-vim.nvim = {
  #   enable = true;
  #   packageNames = [
  #     "nvim"
  #     "nvnix"
  #     "nvnv"
  #   ];
  # };
}
