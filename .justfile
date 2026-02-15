# Install Canonical software
mod canonical ".scripts/canonical.just"
# Install and update Ubuntu packages
mod ubuntu ".scripts/ubuntu.just"

[no-cd, private]
@default:
  just -f {{justfile()}} --list
