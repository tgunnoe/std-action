#!/usr/bin/env bash

set -e
shopt -s lastpipe

function run() {
  local action drv

  jq -r '.action + " " + .targetDrv' <<< "$JSON" | read -r action drv

  echo "::group::Running $action"

  if [[ -n $BUILT ]]; then
    # should be fetched, since we have already checked cache status in build step
    nix-build "$drv" --no-out-link
  elif [[ $BUILDER != auto ]]; then
    nix copy --from "$BUILDER" "$drv"
  fi

  # run the action script
  eval "$(nix show-derivation "$drv" | jq -r '.[].outputs.out.path')"

  echo "::endgroup::"
}

run
