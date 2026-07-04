#!/bin/sh
# Update a flake's lock file, pinning any nixpkgs inputs that track a hydra-built
# NixOS channel to the latest revision that was successfully built on hydra.
#
# Usage: nix-flake-update-hydra [--flake <dir>] [nix flake update options...]
set -euo pipefail

flake_dir="."
passthrough=()
while [ $# -gt 0 ]; do
  case "$1" in
    --flake)
      flake_dir="${2:?--flake requires an argument}"
      shift 2
      ;;
    --flake=*)
      flake_dir="${1#--flake=}"
      shift
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        passthrough+=("$1")
        shift
      done
      ;;
    *)
      passthrough+=("$1")
      shift
      ;;
  esac
done

lock="$flake_dir/flake.lock"
if [ ! -f "$lock" ]; then
  echo "nix-flake-update-hydra: no flake.lock in $flake_dir; run 'nix flake lock' first" >&2
  exit 1
fi

rev_map=$(
  curl -fsSL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \
    | jq -c '.data.result | map({ (.metric.channel): .metric.revision }) | add'
)
if [ -z "$rev_map" ] || [ "$rev_map" = "null" ]; then
  echo "nix-flake-update-hydra: could not fetch channel revisions from hydra" >&2
  exit 1
fi

# Print "name<TAB>url" pairs for each root nixpkgs input whose ref is a known hydra channel.
pairs=$(
  jq -r --argjson revs "$rev_map" '
    .nodes as $nodes
    | $nodes.root.inputs
    | to_entries[]
    | .key as $name
    | .value as $ref
    | (if ($ref | type) == "string" then $nodes[$ref].original else ($ref.original // {}) end) as $o
    | select(
        $o.type == "github"
        and (($o.owner // "") | ascii_downcase) == "nixos"
        and $o.repo == "nixpkgs"
        and (($o.ref // "") | length) > 0
      )
    | select($revs | has($o.ref))
    | "\($name)\tgithub:NixOS/nixpkgs/\($revs[$o.ref])"
  ' "$lock"
)

overrides=()
if [ -n "$pairs" ]; then
  while IFS=$'\t' read -r name url; do
    [ -n "$name" ] || continue
    overrides+=(--override-input "$name" "$url")
  done <<EOF
$pairs
EOF
fi

exec nix flake update "${overrides[@]}" --flake "$flake_dir" "${passthrough[@]}"