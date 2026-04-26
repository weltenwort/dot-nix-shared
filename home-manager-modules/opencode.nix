{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
  };

  home.packages = [
    pkgs.skills
  ];
}
