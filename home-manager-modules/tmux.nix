{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    clock24 = true;
    shell = "${pkgs.fish}/bin/fish";
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
