# OpenCode 2 from llm-agents.nix, installed under the usual `opencode` name.
#
# llm-agents.nix keeps OpenCode 1 as `opencode` and ships OpenCode 2 as a
# separate `opencode2` package whose binary is also called `opencode2`
# (nixpkgs' `opencode` is already 2.x and provides `bin/opencode`). This adds
# `bin/opencode` next to `bin/opencode2` and keeps the `opencode-<version>`
# name, so home-manager's `programs.opencode` sees a 2.x version (it switches
# config formats on `versionAtLeast version "2.0.0"`) and `lib.getExe`
# resolves to `opencode`.
{ pkgs, opencode2 }:
pkgs.symlinkJoin {
  pname = "opencode";
  inherit (opencode2) version;
  name = "opencode-${opencode2.version}";
  paths = [ opencode2 ];
  postBuild = ''
    ln -s opencode2 $out/bin/opencode
  '';
  meta = opencode2.meta // {
    mainProgram = "opencode";
  };
  passthru = (opencode2.passthru or { }) // {
    unwrapped = opencode2;
  };
}
