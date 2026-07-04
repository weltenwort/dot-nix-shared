{ pkgs, ... }:
let
  nix-flake-update-hydra = pkgs.writeShellApplication {
    name = "nix-flake-update-hydra";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.nix
    ];
    text = builtins.readFile ./nix-flake-update-hydra.sh;
  };
in
{
  home.packages = [
    pkgs.nh
    nix-flake-update-hydra
  ];
}