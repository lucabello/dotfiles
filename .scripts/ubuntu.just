set shell := ["bash", "-uc"]

[private]
@default:
  just --justfile {{justfile_directory()}}/.scripts/ubuntu.just --list


# Install Desktop profile
[group('profiles')]
desktop: install-shell install-hyprland install-desktop-apps

# Install Laptop profile
[group("profiles")]
laptop: install-shell install-hyprland install-desktop-apps

# Install Server profile
[group("profiles")]
server: install-shell install-server-apps

[group('install'), doc('Install Shell packages')]
install-shell:
    #!/usr/bin/env bash
    # Add Git PPA before updating packages
    if ! grep -q git-core /etc/apt/sources.list.d/*; then
        sudo apt-add-repository -y ppa:git-core/ppa;
    fi

    # Update and upgrade
    sudo apt update && sudo apt upgrade -y

    # Install all apt packages in one command for performance reasons
    PACKAGES=(
        # Python & tooling
        python3 python-is-python3 pip
        # Shell & terminal
        zsh alacritty
        # Git, LFS & related
        git git-lfs
        # Network & SSH utilities
        curl wget net-tools keychain
        # Build tools & dev libraries
        make build-essential pkg-config cmake libssl-dev
        # Node & npm
        nodejs npm
        # Desktop/clipboard utilities
        xclip xdotool wl-clipboard wtype
        # CLI utilities
        bat tree fd-find fzf ripgrep sshuttle jq eza unzip
        btop ranger git-delta gh
        # Development tools
        shellcheck
        # Dependencies for nvim plugins
        python3.13-venv clang libc6-dev
    )
    sudo apt install -y "${PACKAGES[@]}"

    # Install all snaps
    sudo snap install astral-uv --channel=latest/candidate --classic
    sudo snap install nvim --classic
    sudo snap install go --classic
    sudo snap install yq
    sudo snap install pastel

    # Install go packages
    mkdir -p "$HOME/.local/go" && export GOPATH="$HOME/.local/go" && export PATH="$HOME/.local/go:$PATH"
    go install github.com/zyedidia/eget@latest  # Utility to install from GitHub releases
    go install github.com/jesseduffield/lazygit@latest
    go install github.com/antonmedv/fx@latest  # Terminal JSON viewer & processor
    go install github.com/rs/curlie@latest  # Utility that mixes Curl and HTTPie
    go install github.com/charmbracelet/gum@latest

    # Install rust packages
    which cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    RUSTUP="$HOME/.cargo/bin/rustup"
    CARGO="$HOME/.cargo/bin/cargo"
    $RUSTUP default stable
    which starship || $CARGO install starship --locked  # Starship prompt for ZSH
    which sheldon || $CARGO install sheldon --locked  # Sheldon plugin manager for ZSH
    which tree-sitter || $CARGO install tree-sitter-cli --locked  # nvim plugin
    which macchina || $CARGO install macchina --locked  # fetch command in Rust
    
    # Install python tools with uv
    uv tool install speedtest-cli --force

    # Other installations
    which lazyjournal || curl -sS 'https://raw.githubusercontent.com/Lifailon/lazyjournal/main/install.sh' | bash  # TUI for journald
    which argc || curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sudo sh -s -- --to /usr/local/bin
    which tailscale || curl -fsSL https://tailscale.com/install.sh | sh
    which hledger || eget simonmichael/hledger --upgrade-only --to "$HOME/.local/bin"

    # Shell setup
    mkdir -p "$HOME/VirtualEnvs"
    # Set ZSH as default shell
    if [[ "${SHELL##*/}" != "zsh" ]]; then
        sudo chsh -s /usr/bin/zsh $USER
        sudo chsh -s /usr/bin/zsh
    fi


[group('install'), doc('Install Hyprland')]
install-hyprland:
    #!/usr/bin/env bash
    sudo apt update && sudo apt upgrade -y

    PACKAGES=(
        # Hyprland
        hyprland
        # Hyprland utilities
        nwg-displays hyprpaper hyprland-qtutils hypridle
        # Other utilities
        slurp wl-clipboard wtype brightnessctl
        # Quickshell build dependencies
        qt6-base-dev qt6-declarative-dev qt6-shadertools-dev spirv-tools-dev pkg-config libcli11-dev libcli11-doc qt6-svg-dev qt6-wayland-dev
        libjemalloc-dev libwayland-dev wayland-protocols libdrm-dev libgbm-dev libxcb1-dev libpam0g-dev libpolkit-gobject-1-dev libglib2.0-dev
        ninja-build build-essential
        libxkbcommon-dev qtchooser libegl1-mesa-dev apt info libpipewire-0.3-dev
        "qt6-*dev"
    )
    sudo apt install -y "${PACKAGES[@]}"

    # Install all snaps
    sudo snap install grim

    # Quickshell build deps: google-breakpad
    export GOOGLE_BREAKPAD_VERSION="v2024.02.16"
    if [ -d "/usr/local/include/breakpad/processor" ]; then
        echo "google-breakpad already exists"; 
    else
        test -d /tmp/google-breakpad || git clone https://github.com/google/breakpad.git --branch=$GOOGLE_BREAKPAD_VERSION /tmp/google-breakpad
        test -d /tmp/google-breakpad/src/third_party/lss || git clone https://chromium.googlesource.com/linux-syscall-support /tmp/google-breakpad/src/third_party/lss
        pushd /tmp/google-breakpad
        ./configure && make && sudo make install
        test -d /usr/local/include/breakpad/processor && echo "google-breakpad installed succesfully" && rm -rf /tmp/google-breakpad/
        popd
    fi

    # Quickshell
    export QUICKSHELL_VERSION="v0.2.1"
    if which quickshell; then
        echo "quickshell is already installed"
    else
        test -d /tmp/quickshell || git clone https://git.outfoxxed.me/quickshell/quickshell.git --branch=$QUICKSHELL_VERSION /tmp/quickshell
        pushd /tmp/quickshell
        # Fix the qt6 path thingy
        for component in "/usr/include/x86_64-linux-gnu/qt6"/*; do
            if [ -d "$component" ]; then
                VERSIONED_DIR="$component/6.9.2"
                sudo mkdir -p "$VERSIONED_DIR"
                for file in "$component"/*; do
                    sudo ln -s "$file" "$VERSIONED_DIR/"
                done
                echo "Created symlink in $VERSIONED_DIR for component: $(basename "$component")"
            fi
        done
        cmake -GNinja -B build \
            # -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DCMAKE_PREFIX_PATH=/usr/include/x86_64-linux-gnu/qt6 \
            -DCMAKE_INSTALL_PREFIX="/usr/local" \
            -DINSTALL_QMLDIR="/usr/local/qml" \
            -DINSTALL_QML_PREFIX="qml"
        cmake --build build
        sudo cmake --install build
        # Remove the qt6 symlinks
        sudo find /usr/include/x86_64-linux-gnu/qt6/ -type l -name '*6.9.2*' -exec rm {} +
        popd
    fi


[group('install'), doc('Install Desktop apps')]
install-desktop-apps:
    #!/usr/bin/env bash
    sudo apt update && sudo apt upgrade -y

    PACKAGES=(
        # Rofi
        rofi rofimoji
        # Other utilities
        redshift
    )
    sudo apt install -y "${PACKAGES[@]}"

    sudo snap install obsidian --classic
    sudo apt install -y syncthing && sudo systemctl enable syncthing@aegis.service --now
    sudo systemctl enable --now geoclue.service >/dev/null 2>&1


[group('install'), doc('Install Server Applications')]
install-server-apps:
    #!/usr/bin/env bash
    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update and upgrade
    sudo apt update && sudo apt upgrade -y

    PACKAGES=(
        # OpenSSH server
        openssh-server
        # Others
        ca-certificates curl
        # Docker
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        # Benchmarking
        sysbench
    )
    sudo apt install -y "${PACKAGES[@]}"

    # npm installs
    npm install -g @immich/cli

    # Other installs
    which ctop || sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop && sudo chmod +x /usr/local/bin/ctop
    
    # Server setup
    sudo systemctl enable --now ssh
    groups | grep -q docker || (sudo groupadd docker; sudo usermod -a -G docker $USER)
    ln -s "$HOME/.data/syncthing/Sync" "$HOME/Sync"


[group('update'), doc('Update all packages')]
update:
    # Update and upgrade apt packages
    sudo apt update && sudo apt upgrade -y
    # Refresh snaps
    sudo snap refresh
    # Upgrade go packages
    go install github.com/zyedidia/eget@latest  # Utility to install from GitHub releases
    go install github.com/jesseduffield/lazygit@latest
    go install github.com/antonmedv/fx@latest  # Terminal JSON viewer & processor
    go install github.com/rs/curlie@latest  # Utility that mixes Curl and HTTPie
    go install github.com/charmbracelet/gum@latest
    # Upgrade Rust packages
    rustup update
    cargo install sheldon --locked
    cargo install starship --locked
    cargo install tree-sitter-cli --locked
    cargo install macchina --locked
    # Update python tools installed with uv
    uv tool upgrade --all
    # Upgrade other packages
    eget simonmichael/hledger --upgrade-only --to "$HOME/.local/bin"
    sudo rm -f /usr/local/bin/argc && curl -fsSL https://raw.githubusercontent.com/sigoden/argc/main/install.sh | sudo sh -s -- --to /usr/local/bin
    sudo tailscale update
    
