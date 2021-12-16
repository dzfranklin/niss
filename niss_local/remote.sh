#!/usr/bin/env bash
iex --erl "-proto_dist inet6_tcp" --cookie DUMMY_COOKIE --name darp@darp._peer.internal --remsh niss_local@niss-local._peer.internal
