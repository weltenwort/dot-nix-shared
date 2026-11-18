# Takes the flake inputs so packages can come from llm-agents.nix.
# Installs paseo wrapped with npm on its PATH; see ../packages/paseo.nix.
{ inputs }:
{ pkgs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    (import ../packages/paseo.nix {
      inherit pkgs;
      inherit (llmPkgs) paseo;
    })
  ];
}
