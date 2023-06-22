GITHUB_USERNAME := "lucabello"
CHEZMOI_EXTRA_PATH := "dot_scripts/executable_chezmoi-extra"

[doc("Install chezmoi")]
init:
  # Install chezmoi
  sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init {{ GITHUB_USERNAME }}
  # Initialize variables for chezmoi's first run
  python "$(chezmoi source-path)/{{ CHEZMOI_EXTRA_PATH }} generate-colors"
  python "$(chezmoi source-path)/{{ CHEZMOI_EXTRA_PATH }} generate"

