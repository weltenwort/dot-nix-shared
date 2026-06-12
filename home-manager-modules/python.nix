{ pkgs, ... }:
{
  home.packages = [
    pkgs.python3
    pkgs.uv
    pkgs.pipx
  ];
}
