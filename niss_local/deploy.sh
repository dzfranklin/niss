#!/usr/bin/env bash

# Expected to be run in niss/niss_local

set -euo pipefail

USER="pi"
HOST="niss-local._peer.internal"

# Copy over
rsync -r --exclude=_build --exclude=.elixir_ls --exclude=deps "." "$USER@$HOST:/home/$USER/niss_local"
rsync "../.tool-versions" "$USER@$HOST:/home/$USER/niss_local/.tool-versions"

# Install and build
ssh "$USER@$HOST" "cd ~/niss_local && ./deploy_locally.sh"
