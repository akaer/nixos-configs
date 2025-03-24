# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

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

  boot.loader.grub.enable = true; # Enable GRUB as the bootloader
  boot.loader.grub.device = "nodev"; # Install GRUB on the EFI system partition
  boot.loader.grub.copyKernels = true; # Activate automatic copying of kernel files
  boot.loader.grub.efiSupport = true; # Enable EFI support for GRUB
  boot.loader.grub.enableCryptodisk = true; # Enable GRUB support for encrypted disks
  boot.loader.grub.theme = "${pkgs.catppuccin-grub}";
  boot.loader.efi.efiSysMountPoint = "/boot"; # Mount point of the EFI system partition
  boot.loader.efi.canTouchEfiVariables = true; # Allow GRUB to modify EFI variables for boot entry management

  boot.loader.grub.extraEntries = ''
    menuentry "Reboot" {
        reboot
    }
    menuentry "Poweroff" {
        halt
    }
  '';

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];

  virtualisation.hypervGuest.enable = true;

  networking.hostName = "nixtest"; # Define your hostname.
  networking.wireless.enable = false;
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

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    _7zz
    acpi
    alacritty
    bat
    bc
    binutils
    btop
    colordiff
    curl
    dconf
    direnv
    dunst
    file
    flameshot
    fzf
    ghostty
    git
    htop
    jq
    killall
    linux-firmware
    lxappearance
    mc
    most
    nixpkgs-fmt
    pulseaudioFull
    sqlite
    tmux
    tree
    unrar
    unzip
    vim-full
    watch
    wget
    which
    xclip
    xorg.xdpyinfo
    xorg.xrandr
    xsel
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [ ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Find options: https://nix-community.github.io/home-manager/options.xhtml
  home-manager.users.andrer = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [
        "IosevkaTerm Nerd Font"
      ];
    };

    home.packages = with pkgs; [
      chromium
      vscode
      (pkgs.nerdfonts.override {
        fonts = [
          "IBMPlexMono"
          "Iosevka"
          "IosevkaTerm"
        ];
      })
    ];

    programs.chromium = {
      enable = true;
      extensions = [
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "bnjjngeaknajbdcgpfkgnonkmififhfo" # Fake Filler
        "gneeeeckemnjlgopgpchamgmfpkglgaj" # Proxy Switcher
        "gnldpbnocfnlkkicnaplmkaphfdnlplb" # Test & Feedback
        "efhedldbjahpgjcneebmbolkalbhckfi" # Bug Magnet
      ];
      dictionaries = [
        pkgs.hunspellDictsChromium.en_US
        pkgs.hunspellDictsChromium.de_DE
      ];
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "IosevkaTerm Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "IosevkaTerm Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "IosevkaTerm Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "IosevkaTerm Nerd Font";
            style = "Bold Italic";
          };
        };
      };
    };
    programs.rofi = {
      enable = true;
    };
    programs.powerline-go = {
      enable = true;
    };
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
    };
    programs.bash = {
      enable = true;
      historyControl = [ "ignoreboth" "erasedups" ];
      shellAliases = {
        ll = "ls --color=auto -lha";
        myextip = "curl ipinfo.io/ip";
        grep = "grep --color=auto";
        mv = "mv -i";
        cp = "cp -i";
        ln = "ln -i";
      };
    };
    programs.git = {
      enable = true;
      userName = "André Raabe";
      userEmail = "andre.raabe@gmail.com";
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
    programs.vim = {
      enable = true;
      settings = {
        number = true;
      };
      # Search plugins: nix-env -f '<nixpkgs>' -qaP -A vimPlugins
      plugins = with pkgs.vimPlugins; [
        airline
        vim-airline-themes
        command-t
        fugitive
        nerdtree
        sensible
        supertab
        syntastic
        vim-bufferline
      ];
      extraConfig = ''
        set laststatus=2
        set pastetoggle=<f11>
        let mapleader=","
        set showmatch

        set hlsearch
        set smartcase
        set ignorecase
        set incsearch

        set autoindent
        set expandtab
        set background=dark
        set shiftwidth=4
        set tabstop=4
        set softtabstop=4
        set smarttab
        set smartindent

        set cursorline

        nnoremap <f2> :NERDTreeToggle<cr>
        let g:airline_powerline_fonts=1
        let g:airline_theme='badwolf'
        let g:airline#extensions#tabline#enabled=1
        let g:airline#extensions#tabline#fnamemod=':t'
        let g:airline#extensions#tabline#formatter='unique_tail'

        set t_Co=256
      '';
    };
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      mouse = false;
      prefix = "C-a";
      terminal = "screen-256color";
      # Search plugins: nix-env -f '<nixpkgs>' -qaP -A tmuxPlugins
      plugins = with pkgs; [
        tmuxPlugins.cpu
        tmuxPlugins.sensible
        tmuxPlugins.tmux-powerline
        tmuxPlugins.yank
      ];
      extraConfig = ''
        set -g set-titles on
        set -g set-titles-string "#I:#P - #W - #T"
        set -g update-environment "SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION"
        bind s split-window -v
        bind v split-window -h
        set -g automatic-rename on
      '';
    };

    services.flameshot.enable = true;

    home.stateVersion = "24.11";
  };

  programs = {
    bash.completion.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
  };

  fonts.enableDefaultPackages = true;

  services.acpid.enable = true;

  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];

  services.openssh.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.printing.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      options = "eurosign:e,terminate:ctrl_alt_bksp";
    };
    videoDrivers = [
      "modesetting"
      "fbdev"
    ];
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "andrer";

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "chromium";
  };

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
