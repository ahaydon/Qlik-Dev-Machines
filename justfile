distro := `grep -oP '^ID=\K.*' /etc/os-release`
export ANSIBLE_CONFIG := join(justfile_directory(), "ansible.cfg")

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

# Create a new deployment from a scenario template
create NAME SCENARIO="":
    #!/usr/bin/env bash
    if ["{{SCENARIO}}" == ""]; then
        if command -v fzf >/dev/null 2>&1; then
            scenario=`ls -q scenarios | fzf --prompt="Choose a scenario >"` || exit 1
        else
            just create {{NAME}}
            echo "You must provide a scenario!" 1>&2
            echo -n "Available scenarios: " 1>&2
            ls scenarios
            exit 1
        fi
    else
        scenario="{{SCENARIO}}"
    fi
    mkdir -p deployments
    cp -r scenarios/$scenario deployments/{{NAME}}

_deployment_cmd:
    {{ if parent_directory(invocation_directory()) != join(justfile_directory(), "deployments") {
        error("Command must be run from a deployment.")
    } else {""}
    }}

# Create and start deployment
[group('deployments')]
[no-cd]
up *args: _deployment_cmd
    {{ if path_exists(join(env("PWD"), "ansible_collections")) != "true" { 'just setup' } else { '' } }}
    uv run ansible-playbook -i {{justfile_directory()}}/global.yaml -i inventory.yaml ahaydon.hyperv.up {{args}}

# Stop running instances
[group('deployments')]
[no-cd]
stop *args: _deployment_cmd
    uv run ansible-playbook -i {{justfile_directory()}}/global.yaml -i inventory.yaml ahaydon.hyperv.stop {{args}}

# Destroy deployment
[group('deployments')]
[no-cd]
down *args: _deployment_cmd
    uv run ansible-playbook -i {{justfile_directory()}}/global.yaml -i inventory.yaml ahaydon.hyperv.down {{args}}

# Connect to the virtual machine console
[group('deployments')]
vmconnect VMNAME: _deployment_cmd
    vmconnect.exe localhost {{file_name(env("PWD"))+"-"+VMNAME}} &
