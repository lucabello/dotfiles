# Install Canonical software
mod canonical ".scripts/canonical.just"
# Install and update Ubuntu packages
mod ubuntu ".scripts/ubuntu.just"
# Run scripts directly from dotfiles before 'apply'
mod script ".scripts/script.just"

[no-cd, private]
@default:
  just -f {{justfile()}} --list
