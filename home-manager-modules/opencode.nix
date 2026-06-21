{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
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
        skill = "allow";
        webfetch = "allow";
        websearch = "allow";
        codesearch = "allow";
        question = "allow";
        bash = {
          "gh issue view *" = "allow";
          "ls *" = "allow";
          "head *" = "allow";
          "echo *" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "git diff *" = "allow";
          "git status *" = "allow";
          "git log *" = "allow";
          "git show *" = "allow";
        };
      };
    };
  };

  home.packages = [
    pkgs.skills
    pkgs.nono
  ];

  home.shellAliases = {
    nono-opencode-worktree = "nono run --profile=opencode --allow-cwd --allow $(git rev-parse --git-common-dir)/.. -- opencode";
  };
}
