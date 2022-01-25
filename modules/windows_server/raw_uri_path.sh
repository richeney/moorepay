#!/bin/bash

# trap on any error and run the default_json as a failsafe
set -euo pipefail
trap 'default_json' ERR

default_json()
{
  ## Always return a valid JSON object, using a good default
  ## (If binaries are missing, or repo and branch are not determinable)
  echo "{\"raw_uri_path\":\"https://raw.githubusercontent.com/richeney/scripts/main\"}"
  exit 0
}

# Main

# Requires jq and git
which jq >/dev/null
which git >/dev/null

# Grab origin and branch
branch=$(git branch --show-current)
origin=$(git remote get-url origin | head -1 | grep ^"https://github.com/")
origin=${origin##https://github.com/}
user=${origin%%/*}
repo=${origin##*/}
repo=${repo%%.git}

# Check we have the expected number of words
[[ $(echo $user $repo $branch | wc -w) -eq 3 ]]

# Return the json
echo "{\"raw_uri_path\":\"https://raw.githubusercontent.com/$user/$repo/$branch\"}"

exit 0