# Qlik Dev Machines

## Requirements

- **HyperV** hypervisor for Windows
- **Just** command runner

Just command runner is required and can be installed using the commands below:

### Arch Linux

```sh
sudo pacman -Sy just
```

### Ubuntu

```sh
sudo apt update
sudo apt install just
```

## Preparation

### Build an image

Before deploying virtual machines you need to build a VM image for HyperV, it is recommended to use packer-windoze for this as it automates the build process and can produce images for multiple Windows versions.

[packer-windoze](https://github.com/jborean93/packer-windoze)

Once the image is built it should be placed at `%LOCALAPPDATA%\packer-windoze\images\{image_name}\{image_version}\`

### Set global parameters

Copy the file `global.example.yaml` and name it `global.yaml`, then edit the parameters for your environment, ensuring to enter valid valies for the license details.

The global yaml file can be used to set default values to avoid the need to specify them for each environment, if the same parameter is also set for the environment it will override the global value.

## Deploying scenarios

To deploy a scenario requires running the up command in the scenario directory with the following.

```sh
cd sense_single
just up
```
