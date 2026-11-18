# Takes the flake inputs so packages can come from llm-agents.nix.
{ inputs }:
{ pkgs, ... }:
let
  llmPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.opencode = {
    enable = true;
    package = llmPkgs.opencode;
    settings = {
      permission = {
        "*" = "ask";
        "read" = {
          "*" = "allow";
          "*.env" = "ask";
          "*.env.*" = "ask";
          "/nix/store" = "allow";
        };
        edit = "allow";
        glob = "allow";
        grep = {
          "*" = "allow";
          "*.env" = "ask";
          "*.env.*" = "ask";
        };
        lsp = "allow";
        todowrite = "allow";
        task = "allow";
        skill = "allow";
        webfetch = "allow";
        websearch = "allow";
        codesearch = "allow";
        question = "allow";
        bash = {
          "gh issue view *" = "allow";
          "gh pr view *" = "allow";
          "gh pr diff *" = "allow";
          "ls *" = "allow";
          "head *" = "allow";
          "echo *" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "wc *" = "allow";
          "sort *" = "allow";
          "uniq *" = "allow";
          "tail *" = "allow";
          "rg *" = "allow";
          "cat *" = "allow";
          "git diff *" = "allow";
          "git status *" = "allow";
          "git log *" = "allow";
          "git show *" = "allow";
        };
      };
    };
  };

  home.packages = [
    llmPkgs.skills
    llmPkgs.nono
  ];

  home.shellAliases = {
    nono-opencode-worktree = "nono run --profile=opencode --allow-cwd --allow $(git rev-parse --git-common-dir)/.. -- opencode";
  };
}
