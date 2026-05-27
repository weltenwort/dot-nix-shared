{ pkgs, ... }:
{
  programs.claude-code = {
    enable = true;
  };

  home.packages = [
    pkgs.skills
    pkgs.nono
  ];
}
