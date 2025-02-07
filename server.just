#!/usr/bin/env -S just -f

hostname := `hostname`

[private, no-cd]
@default:
  just -f {{justfile()}} --list

[no-cd]
get-keys:
  #!/usr/bin/env bash
  which bw >/dev/null || sudo snap install bw
  bw login
  export BW_SESSION="$(bw unlock --raw)"
  # Get device SSH keys
  ITEM_ID="$(bw get item {{hostname}} | jq -r .id)"
  bw get attachment --itemid "${ITEM_ID}" "{{hostname}}.pub" # --output "~/.ssh/${HOST}.pub"
  bw get attachment --itemid "${ITEM_ID}" "{{hostname}}" # --output "~/.ssh/${HOST}"
  # Get git SSH keys
  GIT_ITEM_ID="$(bw list items --url="github.com" --search=lucabello | jq -r '.[0].id')"
  bw get attachment --itemid "${GIT_ITEM_ID}" "git.pub" # --output ~/.ssh/git.pub
  bw get attachment --itemid "${GIT_ITEM_ID}" "git" # --output ~/.ssh/git

