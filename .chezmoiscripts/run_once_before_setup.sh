#!/usr/bin/env bash
# Ensure uv and just are installed
which uv || sudo snap install astral-uv --channel=latest/candidate --classic
which just || sudo snap install just --classic

bash dot_scripts/executable_bitwarden-cli fetch-all

CHEZMOI_DIR="$(chezmoi source-path)"
cd "$CHEZMOI_DIR"
bash dot_scripts/executable_chezmoi-data create
PROFILE="$(cat .chezmoidata/metadata.toml | yq -rp toml '.metadata.profile')"
PROFILE="${PROFILE,,}"  # Convert PROFILE to lowercase
just ubuntu "$PROFILE" 

# TODO: Add optional flag to chezmoi-data to toggle Canonical setup
