# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # luks setup
  boot.initrd = {
      luks.devices = {
        luksCrypted = {
          device = "/dev/sda2"; # Replace with your UUID
          preLVM = true; # Unlock before activating LVM
          allowDiscards = true; # Allow TRIM commands for SSDs
        };
      };
      checkJournalingFS = false;
  };

  # Use the GRUB bootloader
  boot.loader.grub.enable = true;  # Enable GRUB as the bootloader
  boot.loader.grub.device = "nodev";  # Install GRUB on the EFI system partition
  boot.loader.grub.copyKernels = true;  # Activate automatic copying of kernel files
  boot.loader.grub.efiSupport = true;  # Enable EFI support for GRUB
  boot.loader.grub.enableCryptodisk = true ; # Enable GRUB support for encrypted disks
  boot.loader.grub.gfxmodeEfi = "1024x768";
  boot.loader.efi.efiSysMountPoint = "/boot";  # Mount point of the EFI system partition
  boot.loader.efi.canTouchEfiVariables = true;  # Allow GRUB to modify EFI variables for boot entry management
  
  # Adds custom menu entries for reboot and poweroff
  boot.loader.grub.extraEntries = ''
      menuentry "Reboot" {
          reboot
      }
      menuentry "Poweroff" {
          halt
      }
  '';

  # Choose Linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "boot.shell_on_fail" ];

  hardware = {
    enableRedistributableFirmware= true;
    cpu.intel.updateMicrocode = true;
    cpu.amd.updateMicrocode = true;
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];

  virtualisation.hypervGuest.enable = true;

  networking.hostName = "nixtest"; # Define your hostname.
  
  # Pick only one of the below networking options.
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };
  
  hardware.graphics.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    _7zz
    acpi
    bc
    btop
    binutils
    curl
    direnv
    file
    git
    htop
    killall
    linux-firmware
    mc
    most
    tmux
    tree
    unrar
    unzip
    vim-full
    which
    watch
    wget
  ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [ "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

