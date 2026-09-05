{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      "terraform_configs.d/*"
      "~/.lima/*/ssh.config"
    ];

    settings = {
      "*".addKeysToAgent = "yes";
    };
  };
}
