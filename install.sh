#!/usr/bin/env bash

nixos-rebuild switch --flake ".#server" --target-host "nils@server" --use-remote-sudo
