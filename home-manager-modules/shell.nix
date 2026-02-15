{
  lib,
  ...
}:
{
  home.sessionVariables = {
    EDITOR = lib.mkDefault "nvim";
    PAGER = lib.mkDefault "bat";
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -la";
    };
    functions = {
      refresh_tmux_vars = ''
        if set -q TMUX
          tmux showenv -s | string replace -rf '^((?:SSH|DISPLAY).*?)=(".*?"); export.*' 'set -gx $1 $2' | source
        end
      '';
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      command_timeout = 1000;
    };
  };

  programs.nix-your-shell = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    tmux.enableShellIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.fd = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
