distro := `grep -oP '^ID=\K.*' /etc/os-release`
export ANSIBLE_CONFIG := "${PWD}/../ansible.cfg"

_default:
    @just --list

# Install dependencies
[no-cd]
setup:
    @just _setup_{{distro}}
    uv run ansible-galaxy collection install -p ansible_collections -r requirements.yaml --force

_setup_arch:
    pacman -Q uv || sudo pacman -Sy --noconfirm --color=always uv

_setup_ubuntu:
    snap list astral-uv >/dev/null || (sudo snap refresh && sudo snap install --classic astral-uv)

create NAME:
    mkdir {{NAME}}

# Deploy environment
[no-cd]
up *args:
    {{ if path_exists(join(env("PWD"), "ansible_collections")) != "true" { 'just setup' } else { '' } }}
    uv run ansible-playbook -i ../global.yaml -i inventory.yaml ahaydon.hyperv.up {{args}}

# Stop running instances
[no-cd]
stop *args:
    uv run ansible-playbook -i ../global.yaml -i inventory.yaml ahaydon.hyperv.stop {{args}}

# Destroy environment
[no-cd]
down *args:
    uv run ansible-playbook -i ../global.yaml -i inventory.yaml ahaydon.hyperv.down {{args}}

vmconnect VMNAME:
    vmconnect.exe localhost {{file_name(env("PWD"))+"-"+VMNAME}} &
