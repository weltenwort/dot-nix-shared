{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "terraform_configs.d/*"
      "~/.lima/*/ssh.config"
    ];

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };
}
