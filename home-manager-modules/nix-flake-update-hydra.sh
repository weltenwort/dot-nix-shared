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

log() { echo "nix-flake-update-hydra: $*" >&2; }

lock="$flake_dir/flake.lock"
if [ ! -f "$lock" ]; then
  log "no flake.lock in $flake_dir; run 'nix flake lock' first"
  exit 1
fi
log "target flake: $flake_dir"

log "fetching latest hydra-built channel revisions..."
rev_map=$(
  curl -fsSL "https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision" \
    | jq -c '.data.result | map({ (.metric.channel): .metric.revision }) | add'
)
if [ -z "$rev_map" ] || [ "$rev_map" = "null" ]; then
  log "could not fetch channel revisions from hydra"
  exit 1
fi
channel_count=$(jq -r 'length' <<<"$rev_map")
log "got $channel_count channel revisions"

# Print "name<TAB>url<TAB>ref" triples for each root nixpkgs input whose ref is
# a known hydra channel.
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
    | "\($name)\tgithub:NixOS/nixpkgs/\($revs[$o.ref])\t\($o.ref)"
  ' "$lock"
)
matched_count=$(printf '%s\n' "$pairs" | grep -c . || true)
if [ "$matched_count" -gt 0 ]; then
  log "matching nixpkgs inputs:"
  printf '%s\n' "$pairs" | while IFS=$'\t' read -r name url ref; do
    [ -n "$name" ] || continue
    log "  $name (ref=$ref) -> $url"
  done
else
  log "no nixpkgs inputs track a hydra channel"
fi

# Identify positional input names (args not starting with "-") the user wants
# to limit the update to. When non-empty, only override the nixpkgs inputs in
# that set; otherwise override all matched nixpkgs inputs.
positionals=()
if [ "${#passthrough[@]}" -gt 0 ]; then
  for arg in "${passthrough[@]}"; do
    case "$arg" in
      -*) ;;
      *) positionals+=("$arg") ;;
    esac
  done
fi
if [ "${#positionals[@]}" -gt 0 ]; then
  log "limiting to inputs: ${positionals[*]}"
fi

overrides=()
if [ -n "$pairs" ]; then
  while IFS=$'\t' read -r name url ref; do
    [ -n "$name" ] || continue
    if [ "${#positionals[@]}" -gt 0 ]; then
      found=0
      for p in "${positionals[@]}"; do
        if [ "$p" = "$name" ]; then
          found=1
          break
        fi
      done
      [ "$found" = 1 ] || continue
    fi
    overrides+=(--override-input "$name" "$url")
  done <<EOF
$pairs
EOF
fi

override_count=$(( ${#overrides[@]} / 2 ))
if [ "$override_count" -gt 0 ]; then
  log "running nix flake update with $override_count override-input flag(s)"
else
  log "running plain nix flake update"
fi
log "command: nix flake update ${overrides[*]:-} --flake $flake_dir ${passthrough[*]:-}"

exec nix flake update "${overrides[@]}" --flake "$flake_dir" "${passthrough[@]}"