{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.git.shared = {
    enable = mkEnableOption "shared git configuration";

    userName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default user name for git commits";
    };

    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default user email for git commits";
    };

    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };
  };

  config = mkIf config.programs.git.shared.enable {
    programs.git = {
      enable = true;
      
      userName = mkIf (config.programs.git.shared.userName != null)
        config.programs.git.shared.userName;
      
      userEmail = mkIf (config.programs.git.shared.userEmail != null)
        config.programs.git.shared.userEmail;

      extraConfig = {
        init.defaultBranch = config.programs.git.shared.defaultBranch;
        pull.rebase = true;
        core.editor = "vim";
        color.ui = true;
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        "*~"
        ".vscode/"
        ".idea/"
      ];
    };
  };
}
