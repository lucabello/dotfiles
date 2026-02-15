#!/usr/bin/env bash
set -euo pipefail
## Setup
# Ensure uv and just are installed
echo "+ Preparing the environment"
which uv >/dev/null 2>&1 || sudo snap install astral-uv --channel=latest/candidate --classic
which just >/dev/null 2>&1 || sudo snap install just --classic
# Prepare environment
CHEZMOI_DIR="$HOME/.local/share/chezmoi"
cd "$CHEZMOI_DIR"
source dot_env
source dot_aliases

## Installation
# Fetch SSH Keys
# echo "+ Fetching SSH Keys from BitWarden"
# bash dot_scripts/executable_bitwarden-cli fetch-keys
# Configure Chezmoi and install things
echo "+ Configuring Chezmoi"
chezmoi-data create
PROFILE="$(chezmoi-data get profile)"
PROFILE="${PROFILE,,}"  # Convert PROFILE to lowercase
echo "+ Installing '${PROFILE,,}' profile"
just --justfile .scripts/ubuntu.just "$PROFILE" 
# Install optional things if enabled
CANONICAL="$(chezmoi-data get canonical)"
CANONICAL="${CANONICAL,,}"  # Convert CANONICAL to lowercase
if [[ "$CANONICAL" == "true" ]]; then 
  echo "+ Installing Canonical working environment"
  just --justfile .scripts/canonical.just charm-dev
fi
