# Takes the flake inputs so packages can come from llm-agents.nix.
{ inputs }:
{ pkgs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    llmPkgs.paseo
  ];
}
