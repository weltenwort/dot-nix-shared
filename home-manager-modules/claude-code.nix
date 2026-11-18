# Takes the flake inputs so packages can come from llm-agents.nix.
{ inputs }:
{ pkgs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.claude-code = {
    enable = true;
    package = llmPkgs.claude-code;
    settings = {
      theme = "dark";
    };
  };

  home.packages = [
    llmPkgs.skills
    # llmPkgs.nono
  ];
}
