#!/usr/bin/env bash

export MIX_TARGET=rpi4
export MIX_ENV=prod

cd niss_ui || exit
mix deps.get
mix assets.deploy
cd ../ || exit

cd niss_fw || exit
mix deps.get
mix firmware
mix upload home.danielzfranklin.org
