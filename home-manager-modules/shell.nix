{ lib
, pkgs
, ...
}:
let
  fish = "${pkgs.fish}/bin/fish";
in
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
    enableFishIntegration = true;
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

    # This replaces the content of ~/.config/direnv/direnvrc
    stdlib = ''
      : "$\{XDG_CACHE_HOME:="$\{HOME}/.cache"}"
      declare -A direnv_layout_dirs
      
      direnv_layout_dir() {
        local hash path
        echo "$\{direnv_layout_dirs[$PWD]:=$(
          hash="$(sha1sum - <<< "$PWD" | head -c40)"
          path="$\{PWD//[^a-zA-Z0-9]/-}"
          echo "$\{XDG_CACHE_HOME}/direnv/layouts/$\{hash}$\{path}"
        )}"
      }
    '';
  };

  programs.btop = {
    enable = true;
  };

  programs.vifm = {
    enable = true;
  };

  home.packages = [
    pkgs.atool
    pkgs.gron
    pkgs.hwatch
    pkgs.jq
    pkgs.poppler-utils
  ];

  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    clock24 = true;
    shell = fish;
    terminal = "screen-256color";
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.onedark-theme;
        extraConfig = ''
          set -g terminal-overrides ",xterm-256color:Tc,xterm-kitty:Tc,xterm-ghostty:Tc"
          set -g @onedark_date_format "%F"
          set -g @onedark_widgets "#[push-default]#{sysstat_cpu} | #{sysstat_mem} | #{sysstat_swap} | #{sysstat_loadavg}#[pop-default]"
        '';
      }
      pkgs.tmuxPlugins.copycat
      pkgs.tmuxPlugins.pain-control
      pkgs.tmuxPlugins.tmux-fzf
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.sysstat
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.open
    ];
    extraConfig = ''
      set -g detach-on-destroy on
      set -sg escape-time 10
    '';
  };
}
