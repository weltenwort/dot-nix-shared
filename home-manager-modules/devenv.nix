{ pkgs, ... }:
{
  home.packages = [
    pkgs.devenv
  ];

  programs.fish.interactiveShellInit = ''
    ${pkgs.devenv}/bin/devenv hook fish | source
  '';
}
