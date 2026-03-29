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

    custom.darwin.linuxBuilder = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable the ncps Lima VM as a remote Linux builder for nix-darwin.";
      };
      sshPort = lib.mkOption {
        type = lib.types.port;
        default = 2222;
        description = "Host port where the ncps VM's SSH is forwarded (see lima/ncps.yaml portForwards).";
      };
      maxJobs = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Maximum number of parallel build jobs dispatched to the ncps builder.";
      };
    };
  };

  config =
    let
      username = config.custom.darwin.mainUser;
      cfg = config.custom.darwin.linuxBuilder;
    in
    lib.mkMerge [
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
      }

      # Remote Linux builder via the ncps Lima VM.
      # The ncps VM's SSH is forwarded to localhost:sshPort (see lima/ncps.yaml).
      # Lima's own key (~/.lima/_config/user) is already authorized in every Lima VM,
      # so no separate key provisioning is required on the macOS side.
      (lib.mkIf cfg.enable {
        nix.distributedBuilds = true;
        nix.settings.builders-use-substitutes = true;
        nix.buildMachines = [
          {
            hostName = "nix-lima-builder";
            protocol = "ssh-ng";
            sshUser = "lima";
            sshKey = "/Users/${username}/.lima/_config/user";
            systems = [ "aarch64-linux" ];
            maxJobs = cfg.maxJobs;
            supportedFeatures = [
              "nixos-test"
              "benchmark"
              "big-parallel"
              "kvm"
            ];
          }
        ];
        # SSH alias so the nix daemon can reach the ncps builder at the forwarded port.
        # StrictHostKeyChecking is disabled because the key changes when ncps is recreated.
        environment.etc."ssh/ssh_config.d/100-nix-lima-builder.conf".text = ''
          Host nix-lima-builder
            Hostname localhost
            Port ${toString cfg.sshPort}
            StrictHostKeyChecking no
            UserKnownHostsFile /dev/null
            ControlMaster auto
            ControlPath /tmp/ssh-nix-builder-%r@%h:%p
            ControlPersist 15m
        '';
      })
    ];
}
