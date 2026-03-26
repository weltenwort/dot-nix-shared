{
  lib,
  pkgs,
  config,
  ...
}:
{
  options = {
    custom.darwin.mainUser = lib.mkOption {
      type = lib.types.str;
      description = "The main user account name for this darwin system.";
    };
  };

  config =
    let
      username = config.custom.darwin.mainUser;
    in
    {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.neovim
      ];

      # Generated using https://hidutil-generator.netlify.app/
      environment.userLaunchAgents."local.remapkeys.plist" = {
        enable = true;
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0">
          <dict>
              <key>Label</key>
              <string>local.remapkeys</string>
              <key>ProgramArguments</key>
              <array>
                  <string>/usr/bin/hidutil</string>
                  <string>property</string>
                  <string>--set</string>
                  <string>{"UserKeyMapping":[
                      {
                        "HIDKeyboardModifierMappingSrc": 0x7000000E7,
                        "HIDKeyboardModifierMappingDst": 0x7000000E6
                      }
                  ]}</string>
              </array>
              <key>RunAtLoad</key>
              <true/>
          </dict>
          </plist>
        '';
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = lib.mkDefault 5;

      system.primaryUser = username;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

      nixpkgs.config = {
        allowUnfree = true;
        allowBroken = false;
        allowUnsupportedSystem = false;
      };

      users.knownUsers = [ username ];
      users.users.${username} = {
        uid = lib.mkDefault 501;
        home = "/Users/${username}";
        shell = pkgs.fish;
      };

      homebrew = {
        enable = true;

        brews = [ ];

        casks = [
          "contexts"
          "thaw"
          "linearmouse"
          "stats"
          "iina"
          "ghostty"
        ];
      };
    };
}
