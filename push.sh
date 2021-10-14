#!/usr/bin/env bash
set -euo pipefail

DIR=$(dirname "$0")

export MIX_TARGET=rpi4
export MIX_ENV=prod

pushd "$DIR/niss_ui" && \
	mix deps.get && \
	mix assets.deploy && \
	popd

pushd "$DIR/niss_fw" && \
	mix deps.get && \
	mix firmware && \
	mix upload home.danielzfranklin.org && \
	popd
