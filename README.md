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
sudo ln -s ~/nixos-configs/$HOSTNAME/configuration.nix /etc/nixos/configuration.nix
sudo ln -s ~/nixos-configs/$HOSTNAME/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
```

## Build the system

```
sudo nixos-rebuild switch
```

## Channels

### List Channels

```
sudo nix-channel --list
```

### Add Channels

To allow working with the home-manager we have to add the channel

```
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
sudo nix-channel --update
```

### System upgrade

```
sudo nix-channel --update
sudo nixos-rebuild switch --upgrade
```

## Cleanup

```
sudo nix-store --gc
sudo nix-collect-garbage --delete-old

sudo nix profile history --profile /nix/var/nix/profiles/system --extra-experimental-features nix-command
sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system --extra-experimental-features nix-command

sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

## Resources

  - https://github.com/enoren5/vbox-nixos-configs/tree/main
  - https://gvolpe.com/blog/home-manager-dotfiles-management/
  - https://github.com/Alan01252/nixos-config/
  - https://github.com/BirdeeHub/birdeeSystems/

