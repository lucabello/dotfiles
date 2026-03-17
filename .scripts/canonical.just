set shell := ["bash", "-uc"]

k8s-channel := '1.35-classic/stable'
juju-channel := '3.6/stable'
snapcraft-channel := '8.x/stable'
charmcraft-channel := '3.x/stable'
rockcraft-channel := 'latest/stable'

ipaddr := `ip -4 -j route get 2.2.2.2 | jq -r '.[] | .prefsrc'`

[private, no-cd]
@default:
    just -f {{justfile_directory()}}/.scripts/canonical.just --list

[group('presets'), doc("Setup a charm development environment"), no-cd]
charm-dev: setup-lxd setup-k8s setup-crafts setup-juju setup-devtools

[group('setup'), doc('Setup Canonical K8s'), no-cd]
setup-k8s:
    sudo snap install k8s --classic --channel={{k8s-channel}}
    sudo k8s bootstrap  # TODO: grep the cluster status from 'sudo k8s status' and ignore if already ready
    sudo k8s status --wait-ready
    sudo k8s enable local-storage
    sudo k8s enable load-balancer
    sudo k8s set load-balancer.l2-mode=true load-balancer.cidrs="{{ipaddr}}/32"
    sudo k8s status --wait-ready
    mkdir -p ~/.kube
    sudo k8s kubectl config view --raw | sudo tee ~/.kube/config >/dev/null && sudo chown -f -R $USER ~/.kube

[group('setup'), doc('Setup LXD'), no-cd]
setup-lxd:
    sudo snap install lxd && sudo usermod -aG lxd $USER
    exec sg lxd "lxd init --auto"
    if which ufw; then sudo ufw allow in on lxdbr0; sudo ufw route allow in on lxdbr0; sudo ufw route allow out on lxdbr0; fi

[group('setup'), doc('Setup Juju'), no-cd]
setup-juju:
    sudo snap install juju --channel={{juju-channel}}
    sudo k8s config | sudo -u $USER /snap/juju/current/bin/juju add-k8s k8s --client

[group('setup'), doc('Setup Juju and Craft-tools'), no-cd]
setup-crafts:
    sudo snap install rockcraft --classic --channel={{rockcraft-channel}}
    sudo snap install charmcraft --classic --channel={{charmcraft-channel}}
    sudo snap install snapcraft --classic --channel={{snapcraft-channel}}

[group('setup'), doc('Setup developer tools'), no-cd]
setup-devtools:
    if ! which uv; then sudo snap install astral-uv --classic; fi
    if ! which tox; then uv tool install tox; fi
    sudo snap install multipass
    sudo snap install kubectl --classic
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
    # Install GRPC TUI client
    go install github.com/felangga/chiko/cmd/chiko@latest

[group('dev'), doc('Spin up a Multipass VM with the otelcol snap'), no-cd]
create-otelcol-vm:
    multipass launch --cpus=2 --memory=4G --disk=50G --name otelcol-test
    multipass exec otelcol-test -- sudo snap install opentelemetry-collector --channel=edge
    multipass exec otelcol-test -- suod mkdir -p /etc/otelcol/config.d
    multipass exec otelcol-test -- sudo snap connect opentelemetry-collector:etc-otelcol-config
    # Observe logs
    multipass exec otelcol-test -- sudo snap connect opentelemetry-collector:log-observe
    # Remember to manually start the snap with 'sudo snap start opentelemetry-collector' !
