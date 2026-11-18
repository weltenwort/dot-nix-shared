# Takes the flake inputs so packages can come from llm-agents.nix.
{ inputs }:
{ pkgs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.herdr = {
    enable = true;
    package = llmPkgs.herdr;
    settings = {
      onboarding = false;
      theme = {
        name = "one-dark";
        auto_switch = false;
      };
      ui = {
        show_agent_labels_on_pane_borders = true;
        toast.delivery = "terminal";
        sound.enabled = false;
      };
      keys.prefix = "ctrl+a";
      worktrees.directory = "~/worktrees";
    };
  };
}

