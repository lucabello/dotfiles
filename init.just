#!/usr/bin/env -S just -f
set allow-duplicate-recipes
import 'ubuntu.just'

hostname := `hostname`

[private, no-cd]
@default:
  echo "Available presets:"
  echo "    desktop  # Initialize a Desktop"
  echo "    laptop   # Initialize a Laptop"
  echo "    server   # Initialize a Home Server"


[no-cd, group('profile'), doc('Setup Desktop')]
desktop: get-keys install-shell install-xmonad install-desktop-apps (configure-chezmoi "desktop")

[no-cd, doc('Setup Laptop')]
laptop: get-keys install-shell install-xmonad install-desktop-apps (configure-chezmoi "laptop")

[no-cd, doc('Setup Home Server')]
server: get-keys install-shell install-server-apps (configure-chezmoi "server")


[private, no-cd]
get-keys:
  #!/usr/bin/env bash
  which bw >/dev/null || sudo snap install bw
  bw login
  export BW_SESSION="$(bw unlock --raw)"
  # Prepare the temporary folder
  TMP_FOLDER="$(mktemp --directory --tmpdir="$HOME")"
  cd "$TMP_FOLDER"
  # Get device SSH keys
  ITEM_ID="$(bw get item {{hostname}} | jq -r .id)"
  bw get attachment --itemid "{item_id}}" "{{hostname}}.pub" && chmod 644 "{{hostname}}.pub"
  bw get attachment --itemid "{item_id}}" "{{hostname}}" && chmod 600 "{{hostname}}"
  if [[ -f "{{hostname}}" ]]; then mv "{{hostname}}.pub" ~/.ssh/ && mv "{{hostname}}" ~/.ssh/; fi
  # Get git SSH keys
  GIT_ITEM_ID="$(bw list items --url='github.com' --search=lucabello | jq -r '.[0].id')"
  bw get attachment --itemid "$GIT_ITEM_ID" "git.pub" && chmod 644 "git.pub"
  bw get attachment --itemid "$GIT_ITEM_ID" "git" && chmod 600 "git"
  if [[ -f "git" ]]; then mv git.pub ~/.ssh/ && mv git ~/.ssh/; fi
  echo "Removing $TMP_FOLDER" && rmdir "$TMP_FOLDER"

[private, no-cd]
configure-chezmoi profile:
  #!/usr/bin/env bash
  CHEZMOI_PATH="$($HOME/.local/bin/chezmoi source-path)"
  if [[ ! -f "$CHEZMOI_PATH/.variables.json" ]]; then
    TMP_FOLDER="$(mktemp --directory)"
    cd "$TMP_FOLDER"
    cp "$CHEZMOI_PATH/dot_scripts/executable_chezmoi-extra" chezmoi-extra
    chmod +x chezmoi-extra
    ./chezmoi-extra complete-colors >/dev/null
    ./chezmoi-extra generate --profile="{{profile}}" --no-apply
    rm chezmoi-extra && rmdir "$TMP_FOLDER"
  fi
  chezmoi apply
