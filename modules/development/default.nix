{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.development.shared = {
    enable = mkEnableOption "shared development tools configuration";

    tools = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional development tools to install";
    };

    enableCommonTools = mkOption {
      type = types.bool;
      default = true;
      description = "Enable common development tools (git, curl, wget, jq)";
    };
  };

  config = mkIf config.programs.development.shared.enable {
    home.packages = with pkgs; 
      (optionals config.programs.development.shared.enableCommonTools [
        curl
        wget
        jq
        tree
      ])
      ++ config.programs.development.shared.tools;
  };
}
