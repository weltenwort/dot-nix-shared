{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
    settings = {
      theme = "dark";
    };
  };

  home.packages = [
    pkgs.skills
    # pkgs.nono
  ];
}
