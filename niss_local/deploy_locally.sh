#!/usr/bin/env bash

# Run by deploy.sh. Expect to be run in niss/niss_local

set -euo pipefail

. "$HOME/env"
ASDF="$HOME/.asdf/bin/asdf"
export MIX_ENV=prod

"$ASDF" install
"$ASDF" exec mix local.hex --force
"$ASDF" exec mix local.rebar --force
"$ASDF" exec mix deps.get
"$ASDF" exec mix deps.compile --force sentry
"$ASDF" exec mix release

sudo systemctl restart niss-local
