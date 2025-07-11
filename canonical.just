#!/usr/bin/env -S just -f
microk8s-channel := '1.32-strict/stable'
juju-channel := '3.6/stable'
rockcraft-channel := 'latest/candidate'
charmcraft-channel := '3.x/candidate'

ipaddr := `ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc'`

[private, no-cd]
@default:
    just -f {{justfile_directory()}}/canonical.just --list

[group('presets'), doc("Setup a charm development environment"), no-cd]
charm-dev: setup-microk8s setup-lxd setup-juju setup-dev

[group('setup'), doc('Setup MicroK8s'), no-cd]
setup-microk8s:
    sudo snap install microk8s --channel={{microk8s-channel}}
    mkdir -p "$HOME"/.kube
    sudo usermod -aG snap_microk8s $USER
    exec sg snap_microk8s "microk8s config > ~/.kube/config && sudo chown -f -R $USER ~/.kube"
    exec sg snap_microk8s "microk8s status --wait-ready"
    exec sg snap_microk8s "sudo microk8s enable dns hostpath-storage ingress rbac && microk8s status --wait-ready"
    exec sg snap_microk8s "sudo microk8s enable metallb:{{ipaddr}}-{{ipaddr}} && microk8s status --wait-ready"
    exec sg snap_microk8s "sudo microk8s enable registry --wait-ready"

[group('setup'), doc('Setup LXD'), no-cd]
setup-lxd:
    sudo snap install lxd && sudo usermod -aG lxd $USER
    exec sg lxd "lxd init --auto"

[group('setup'), doc('Setup Juju and Craft-tools'), no-cd]
setup-juju:
    sudo snap install juju --channel={{juju-channel}}
    sudo snap install rockcraft --classic --channel={{rockcraft-channel}}
    sudo snap install charmcraft --classic --channel={{charmcraft-channel}}

[group('setup'), doc('Setup developer tools'), no-cd]
setup-dev:
    if ! which uv; then sudo snap install astral-uv --classic; fi
    if ! which tox; then uv tool install tox; fi
    sudo snap install jhack && sudo snap connect jhack:dot-local-share-juju snapd 
    cargo install --git https://github.com/sed-i/juju-graph
    # go install github.com/snapcore/spread/cmd/spread@latest
    curl -fsSL https://goss.rocks/install | sudo sh
    # Install GH and GH Dashboard
    if ! which gh; then \
        sudo curl -fsSLo /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        https://cli.github.com/packages/githubcli-archive-keyring.gpg; \
        echo "deb [arch=$(dpkg --print-architecture) \
        signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" | \
        sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null; \
        sudo apt update && sudo apt install gh -y; \
    fi
