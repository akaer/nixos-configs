# NIXOS tests

## Cloning this repo

```
cd ~
git clone git@github.com:akaer/nixos-configs.git
```

## Activate config

As the NIXOS configuration is maintained inside this GIT repository we have to make the system aware of this files.
This can easily be done by symlinking the configs:

```
sudo ln -s ~/nixos-configs/<hostname>/configuration.nix /etc/nixos/configuration.nix
sudo ln -s ~/nixos-configs/<hostname>/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
```

## Build the system

```
sudo nixos-rebuild switch
```

## Cleanup

```
sudo nix-store --gc

sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

## Resources

https://github.com/enoren5/vbox-nixos-configs/tree/main
