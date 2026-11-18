# Wraps paseo so nodejs (and therefore npm) is on paseo's own PATH.
#
# The paseo daemon prepares npm plugins by running a plugin manifest's `build`
# commands (e.g. `npm ci`) and resolves `npm` from its own PATH. The
# llm-agents.nix package runs on a store node but exposes no npm, so plugin
# installs fail with `spawn npm ENOENT`. The CLI starts the daemon with its own
# environment, so wrapping both binaries covers the daemon too. Prefixing PATH
# in the wrapper (instead of installing nodejs into the profile) keeps
# node/npm out of other shells.
#
# A daemon started from an unwrapped paseo keeps its old environment: run
# `paseo daemon stop` and start it again from the wrapped CLI after switching
# (`paseo daemon restart` reuses the old supervisor launch).
{ pkgs, paseo }:
let
  # Use the exact node the package was built with; fall back to the same major.
  nodejs = paseo.nodejs or pkgs.nodejs_22;
in
pkgs.symlinkJoin {
  name = "paseo-${paseo.version}";
  paths = [ paseo ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    for bin in paseo paseo-server; do
      if [ -e "$out/bin/$bin" ]; then
        wrapProgram "$out/bin/$bin" --prefix PATH : ${pkgs.lib.makeBinPath [ nodejs ]}
      fi
    done
  '';
  inherit (paseo) meta;
  passthru = {
    inherit nodejs;
    unwrapped = paseo;
    inherit (paseo) version;
  };
}
