{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.shell.shared = {
    enable = mkEnableOption "shared shell configuration";

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Shell aliases to set";
    };

    enableBashIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable bash integration";
    };

    enableZshIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh integration";
    };
  };

  config = mkIf config.programs.shell.shared.enable {
    home.shellAliases = mkMerge [
      {
        ll = "ls -lh";
        la = "ls -lah";
        ".." = "cd ..";
        "..." = "cd ../..";
      }
      config.programs.shell.shared.aliases
    ];

    programs.bash = mkIf config.programs.shell.shared.enableBashIntegration {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoredups" "ignorespace" ];
    };

    programs.zsh = mkIf config.programs.shell.shared.enableZshIntegration {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
