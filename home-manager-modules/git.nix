{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.git;
in
{
  options.custom.git = {
    userEmail = lib.mkOption {
      default = "weltenwort@users.noreply.github.com";
      type = lib.types.str;
      description = "The email address to use for git commits.";
    };
    userName = lib.mkOption {
      default = "Felix Stürmer";
      type = lib.types.str;
      description = "The user name to use for git commits.";
    };
  };

  config = {
    programs.git = {
      enable = true;

      userEmail = cfg.userEmail;
      userName = cfg.userName;

      ignores = [
        ".vscode"
        ".envrc"
        ".direnv"
      ];

      extraConfig = {
        merge.conflictstyle = "diff3";
        merge.tool = "fugitive";
        mergetool.splice = {
          cmd = "vim -f $BASE $LOCAL $REMOTE $MERGED -c 'SpliceInit'";
          trustExitCode = true;
        };
        mergetool.fugitive = {
          cmd = ''nvim -f -c "Gdiffsplit!" "$MERGED"'';
        };
        fetch.prune = true;
      };
    };

    programs.gh = {
      enable = true;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
      };
      gitCredentialHelper = {
        enable = true;
      };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        side-by-side = true;
      };
    };

    programs.less = {
      enable = true;
    };

    home.sessionVariables = {
      DELTA_PAGER = "less -RFX";
    };

    home.packages = [
      pkgs.gitui
    ];

    home.shellAliases = {
      gst = "git status";
      glol = "git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
      gd = "git diff";
      gdca = "git diff --cached";
      gc = "git commit";
      gca = "git commit --amend";
      gcA = "git commit -a";
      gco = "git checkout";
      ga = "git add";
      gau = "git add -u";
    };

    xdg.configFile."gitui/theme.ron".text = ''
      (
        selected_tab: Reset,
        command_fg: Blue,
        selection_bg: DarkGray,
        cmdbar_extra_lines_bg: Blue,
        disabled_fg: Gray,
        diff_line_add: Green,
        diff_line_delete: Red,
        diff_file_added: LightGreen,
        diff_file_removed: LightRed,
        diff_file_moved: LightMagenta,
        diff_file_modified: Yellow,
        commit_hash: Magenta,
        commit_time: LightCyan,
        commit_author: Green,
        danger_fg: Red,
        push_gauge_bg: Blue,
        push_gauge_fg: Reset,
      )
    '';
  };
}
