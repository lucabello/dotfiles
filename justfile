# Install Canonical blueprints
mod canonical
# Initialize a new machine
mod init
# Install and update Ubuntu packages
mod ubuntu

[no-cd, private]
@default:
  just -f {{justfile()}} --list
