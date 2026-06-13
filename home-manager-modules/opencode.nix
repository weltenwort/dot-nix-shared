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
        };
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
        };
      };
    };
  };

  home.packages = [
    pkgs.skills
    pkgs.nono
  ];
}
