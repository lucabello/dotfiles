set shell := ["bash", "-uc"]


[private]
@default:
  just --justfile {{justfile_directory()}}/.scripts/script.just --list

[no-cd]
bitwarden-cli *args:
  bash dot_scripts/executable_bitwarden-cli {{args}}

nerdfonts *args:
  bash dot_scripts/executable_nerdfonts {{args}}

[no-cd]
chezmoi-data *args:
  source dot_aliases; chezmoi-data {{args}}

[no-cd]
chezmoi-theme *args:
  source dot_aliases; chezmoi-theme {{args}}
