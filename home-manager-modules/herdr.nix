{ pkgs, ... }:
{
  programs.herdr = {
    enable = true;
    settings = {
      onboarding = false;
      theme = {
        name = "one-dark";
        auto_switch = false;
      };
      ui = {
        show_agent_labels_on_pane_borders = true;
        toast.delivery = "terminal";
        sound.enabled = false;
      };
      keys.prefix = "ctrl+a";
    };
  };
}