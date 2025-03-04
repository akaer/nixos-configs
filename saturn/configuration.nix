# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.checkJournalingFS = false;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "boot.shell_on_fail" ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    cpu.amd.updateMicrocode = true;
  };

  networking.hostName = "saturn"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  hardware.graphics.enable = true;

  services.libinput.enable = true;
  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    desktopManager = { xterm.enable = false; };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [ "networkmanager" "wheel" ];
    #packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
	_7zz
	acpi
        bc
        chromium
	btop
	direnv
	dunst
	feh
	file
	firefox-esr
	flameshot
	fzf
	ghostty
	git
	gnome-keyring
	htop
	jq
	killall
	libnotify
	linuxKernel.packages.linux_6_6.virtualboxGuestAdditions
	lxappearance
	mc
	most
	neofetch
	nerdfonts
	networkmanagerapplet
	pasystray
	powerline
	powerline-fonts
	powerline-symbols
	pulseaudioFull
	rofi
	scrot
	sshfs
	tldr
	tmux
	tmuxPlugins.sensible
	tmuxPlugins.tmux-fzf
	tmuxPlugins.tmux-powerline
	tree
	unrar
	unzip
	vim-full
	watch
	wget
	xclip
	xfce.thunar
	xorg.xauth
	xorg.xf86inputvmmouse
	xorg.xf86videovesa
	xorg.xinit
	xorg.xinput
	xorg.xkbcomp
	xorg.xrandr
	xorg.xset
	xterm
  ];

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "ghostty";
    BROWSER = "chromium";
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
