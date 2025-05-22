set shell := ["bash", "-uc"]

[private]
@default:
  just -f {{justfile_directory()}}/ubuntu.just --list

[group('install'), doc('Install Shell packages')]
install-shell:
    sudo apt update && sudo apt upgrade -y
    # Install Python and related utilities
    sudo apt install -y python3 python-is-python3 pip
    # Install uv
    sudo snap install astral-uv --channel=latest/candidate
    mkdir -p "$HOME/VirtualEnvs"
    # Install shell and terminal
    sudo apt install -y zsh alacritty
    # Set ZSH as default shell
    if [[ "${SHELL##*/}" != "zsh" ]]; then \
        chsh -s /usr/bin/zsh; sudo chsh -s /usr/bin/zsh; \
    fi
    # Add Git PPA for latest version
    if ! grep -q git-core /etc/apt/sources.list.d/*; then \
        sudo apt-add-repository ppa:git-core/ppa; \
        sudo apt-get update && sudo apt-get install -y git; \
    fi
    # Install common build tools
    sudo apt install -y make
    which cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    "$HOME"/.cargo/bin/rustup default stable
    sudo snap install node --classic
    sudo snap install go --classic
    # Install AstroNvim (prerequisites)
    sudo apt install -y neovim
    "$HOME"/.cargo/bin/cargo install tree-sitter-cli --locked
    go install github.com/jesseduffield/lazygit@latest
    # Install Sheldon plugin manager for ZSH
    sudo apt install -y pkg-config cmake
    "$HOME"/.cargo/bin/cargo install sheldon --locked
    # Install the Starship prompt for ZSH
    "$HOME"/.cargo/bin/cargo install starship --locked
    # Install Network and SSH utilities
    sudo apt install -y curl wget net-tools keychain
    # Install Desktop-interface utilities
    sudo apt install -y xclip xdotool
    # Install CLI utilities
    sudo apt install -y bat tree fd-find fzf ripgrep sshuttle jq eza unzip
    sudo apt install -y btop ranger
    sudo snap install json-tui
    sudo snap install yq 
    sudo snap install httpie
    sudo snap install pastel
    uv tool install speedtest-cli --force
    # Development tools
    sudo apt install -y shellcheck
    which argc || curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sudo sh -s -- --to /usr/local/bin
    mkdir -p ~/.local/go && export GOPATH=~/.local/go && go install github.com/charmbracelet/gum@latest
    # Tailscale
    curl -fsSL https://tailscale.com/install.sh | sh
    # Other apps
    sudo apt install -y hledger
    "$HOME"/.cargo/bin/cargo install macchina --locked
    # Chezmoi
    if [[ ! -f "$HOME/.local/bin/chezmoi" ]]; then \
      pushd "$HOME"; \
      sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init lucabello; \
      popd; \
    fi

[group('install'), doc('Install XMonad')]
install-xmonad:
    #!/usr/bin/env bash
    # Install KDE
    sudo apt install -y kde-plasma-desktop
    ## Install XMonad
    sudo apt install -y xmonad libghc-xmonad-dev libghc-xmonad-contrib-dev xmobar
    ## Install the compositor
    sudo apt install -y picom
    ## Create the service
    SYSTEMD_FOLDER="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_FOLDER"
    PLASMA_CUSTOM_WM='[Install]
    WantedBy=plasma-workspace.target

    [Unit]
    Description=Plasma Custom Window Manager
    Before=plasma-workspace.target

    [Service]
    ExecStart=/usr/bin/xmonad
    Slice=session.slice
    Restart=on-failure'
    if test -f $SYSTEMD_FOLDER/plasma-custom-wm.service; then
        echo "XMonad (on KDE) session file already exists.";
    else
        echo "Writing session file for XMonad (on KDE)"
        echo "$PLASMA_CUSTOM_WM" > $SYSTEMD_FOLDER/plasma-custom-wm.service;
    fi
    ## Enable the service
    systemctl --user is-enabled plasma-custom-wm.service || systemctl --user enable plasma-custom-wm.service

[group('install'), doc('Install Desktop apps')]
install-desktop-apps:
    # Install UI components
    ## Install Polybar
    sudo apt install -y mpd polybar
    ## Install Rofi
    sudo apt install -y rofi rofi-dev
    ## Install Rofi Emoji
    uv tool install rofimoji
    ## Install Dunst
    sudo apt install -y dunst
    ## Install Redshift
    sudo apt install -y redshift
    ## Install Spectactle (screenshots)
    sudo apt install -y kde-spectacle
    ## Install Flameshot (screenshots)
    sudo apt install -y flameshot
    ## Install fonts
    cp "$(chezmoi source-path)/dot_scripts/executable_nerdfonts" /tmp/nerdfonts; chmod +x /tmp/nerdfonts; /tmp/nerdfonts install --font Monofur --font SpaceMono; rm /tmp/nerdfonts
    # Install Desktop applications
    sudo snap install vivaldi
    sudo snap install obsidian --classic
    sudo apt install -y syncthing && sudo systemctl enable syncthing@aegis.service --now
    # Activate Bluetooth
    systemctl is-enabled bluetooth.service || sudo systemctl enable bluetooth.service --now
    # Install Brave Browser
    if ! which brave-browser; then \
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; \
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
        https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list; \
        sudo apt update && sudo apt install -y brave-browser; \
    fi
    # Install Spotify
    if ! which spotify; then \
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | \
        sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg; \
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list; \
        sudo apt update && sudo apt install -y spotify-client; \
    fi
    # Install ueberzugpp (requirement for something, I don't remember what)
    echo 'deb http://download.opensuse.org/repositories/home:/justkidding/xUbuntu_24.04/ /' \
        sudo tee /etc/apt/sources.list.d/home:justkidding.list; \
        curl -fsSL https://download.opensuse.org/repositories/home:justkidding/xUbuntu_24.04/Release.key \
        | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_justkidding.gpg > /dev/null; \
        sudo systemctl daemon-reload; sudo apt update; sudo apt install ueberzugpp
    sudo apt install -y mplayer

[group('install'), doc('Install Server Applications')]
install-server-apps:
    # OpenSSH server
    sudo apt install openssh-server
    sudo systemctl enable --now ssh
    # Docker
    ## Add Docker's official GPG key:
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    ## Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ## Install Docker
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    groups | grep -q docker || (sudo groupadd docker; sudo usermod -a -G docker $USER; sudo snap disable docker && sudo snap enable docker)
    # CTop for Docker
    sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop && sudo chmod +x /usr/local/bin/ctop
    # Benchmarking
    sudo apt -y install sysbench
    # AI things
    sudo snap install ollama


[group('update'), doc('Update all packages')]
update:
    # Update and upgrade apt packages
    sudo apt update
    sudo apt upgrade
    # Refresh snaps
    sudo snap refresh
    # Upgrade Shell-related packages
    rustup update
    cargo install sheldon --locked
    cargo install starship --locked
    cargo install macchina --locked
    ## Update argc
    sudo rm -f /usr/local/bin/argc && curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sudo sh -s -- --to /usr/local/bin
    ## Update gum
    go install github.com/charmbracelet/gum@latest
    # Update Tailscale
    sudo tailscale update
    # Update AstroNvim
    cargo install tree-sitter-cli --locked
    go install github.com/jesseduffield/lazygit@latest
    vim +AstroUpdate +qa
    # Update uv-installed tools
    uv tool upgrade --all
