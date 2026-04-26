{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      permission = {
        "*" = "ask";
        "read" = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        glob = "allow";
        grep = "allow";
        lsp = "allow";
        task = "allow";
        skill = "allow";
        webfetch = "allow";
        websearch = "allow";
        codesearch = "allow";
        question = "allow";
      };
    };
  };

  home.packages = [
    pkgs.skills
  ];
}
