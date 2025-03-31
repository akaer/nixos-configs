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
        device = "/dev/nvme0n1p2"; # Replace with your UUID
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

  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  boot.blacklistedKernelModules = ["nouveau"];

  boot.kernelPackages = pkgs.linuxPackages;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];

  networking.hostName = "mars"; # Define your hostname.
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      Wolkenkuckucksheim = {
        authProtocols = [
          "WPA-PSK"
          "WPA-PSK-SHA256"
        ];
        pskRaw = "69728e0f38eaf31ee08ba76d4104202e05f7212d5d5323d8c96da4b03c29fa66";
      };
      open_wifi_stealing_ur_datas = {};
    };
  };

  networking.networkmanager.enable = false;

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
    colors = [ "2e3440" "bf616a" "a3be8c" "d08770" "81a1c1" "b48ead" "88c0d0" "8fbcbb" "3b4252" "bf616a" "5e81ac" "8fbcbb" "8fbcbb" "434c5e" "d8dee9" "ebcb8b" ]; # blue red green orange light-blue pink cyan? light-pink(turquoise)? polar-night2 deepred teal lessteal purple grey
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # To allow Firefox addons
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/main.tar.gz") {
      inherit pkgs;
    };
  };

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
    litecli
    lxappearance
    mc
    most
    ncdu
    nixpkgs-fmt
    pulseaudioFull
    glow
    sqlite
    tmux
    tree
    unrar
    unzip
    vim-full
    watch
    wget
    which
    wireshark
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
        "Iosevka Nerd Font"
      ];
    };

    home.sessionVariables = {
      PROMPT_COMMAND = "history -a";
    };

    home.packages = with pkgs; [
      corefonts
      nordic
      scrcpy
      vscode
      (pkgs.nerdfonts.override {
        fonts = [
          "Iosevka"
        ];
      })
    ];

    programs.firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "de"
      ];
      # https://mozilla.github.io/policy-templates/
      policies = {
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAccounts = true;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisablePasswordReveal = true;
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "always";
        DontCheckDefaultBrowser = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        SearchBar = "unified";
      };
      profiles = {
        default = {
          id = 0;
          settings = {
            "extensions.autoDisableScopes" = 0;
            "extensions.update.enabled" = false;
            "browser.aboutConfig.showWarning" = false;
            "browser.contentblocking.category" = "standard";
            "privacy.donottrackheader.enabled" = true;
            "widget.disable-workspace-management" = true;
            "browser.startup.homepage" = "about:home";
            "browser.search.region" = "US";
            "browser.search.isUS" = false;
            "browser.search.defaultenginename" = "DuckDuckGo";
            "browser.search.order.1" = "DuckDuckGo";
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.newtabpage.pinned" = "";
            "browser.topsites.contile.enabled" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "doh-rollout.balrog-migration-done" = true;
            "doh-rollout.doneFirstRun" = true;
            "dom.forms.autocomplete.formautofill" = false;
          };
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            darkreader
            link-cleaner
            privacy-badger
            ublock-origin
            foxyproxy-standard
            i-dont-care-about-cookies
            languagetool
          ];
        };
      };

    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    xresources.extraConfig = builtins.readFile (
      pkgs.fetchFromGitHub
        {
          owner = "nordtheme";
          repo = "xresources";
          rev = "ba3b1b61bf6314abad4055eacef2f7cbea1924fb";
          sha256 = "sha256-vw0lD2XLKhPS1zElNkVOb3zP/Kb4m0VVgOakwoJxj74=";
        } + "/src/nord"
    );

    programs.bat = {
      enable = true;
      config = {
        theme = "Nord";
        pager = "less -FR";
      };
    };

    programs.btop = {
      enable = true;
      settings = {
        truecolor = true;
        color_theme = "nord";
        theme_background = true;
      };
    };

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
            family = "Iosevka Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "Iosevka Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "Iosevka Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "Iosevka Nerd Font";
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
      newline = true;
      settings = {
        hostname-only-if-ssh = true;
        numeric-exit-codes = true;
        theme = "gruvbox";
      };
      modules = [
        "time"
        "user"
        "host"
        "ssh"
        "cwd"
        "gitlite"
        "nix-shell"
      ];
    };
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      tmux.enableShellIntegration = true;
      defaultOptions = ["--color 16"];
    };
    programs.bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [ "ignoreboth" "erasedups" ];
      historyFileSize = 90000;
      historySize = 10000;
      historyIgnore = [
        "?"
        "??"
        "???"
        "bash"
        "clear"
        "exit"
        "man*"
        "*--help"
      ];
      bashrcExtra = ''
        # Workaround for nix-shell --pure
        if [ "$IN_NIX_SHELL" == "pure" ]; then
            if [ -x "$HOME/.nix-profile/bin/powerline-go" ]; then
                alias powerline-go="$HOME/.nix-profile/bin/powerline-go"
            elif [ -x "/run/current-system/sw/bin/powerline-go" ]; then
                alias powerline-go="/run/current-system/sw/bin/powerline-go"
            fi
        fi
      '';
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
      lfs.enable = true;
      userName = "André Raabe";
      userEmail = "andre.raabe@gmail.com";
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        graph = "log --decorate --oneline --graph";
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
        command-t
        fugitive
        nerdtree
        nord-vim
        sensible
        supertab
        syntastic
        vim-airline-themes
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
        set shiftwidth=4
        set tabstop=4
        set softtabstop=4
        set smarttab
        set smartindent

        set cursorline

        nnoremap <f2> :NERDTreeToggle<cr>

        " this is needed to let vim do the color stuff correctly within just alacritty
        if (has("termguicolors"))
          set termguicolors
        endif
        "set t_Co=256

        let g:airline_powerline_fonts=1
        let g:airline_theme='nord'
        let g:airline#extensions#tabline#enabled=1
        let g:airline#extensions#tabline#fnamemod=':t'
        let g:airline#extensions#tabline#formatter='unique_tail'

        colorscheme nord
        let g:nord_italic = 1
        let g:nord_italic_comments = 1
        let g:nord_underline = 1
        let g:nord_cursor_line_number_background = 1
      '';
    };
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      prefix = "C-a";
      terminal = "tmux-256color";
      # Search plugins: nix-env -f '<nixpkgs>' -qaP -A tmuxPlugins
      plugins = with pkgs.tmuxPlugins; [
        battery
        cpu
        fzf-tmux-url
        nord
        prefix-highlight
        sensible
        yank
      ];
      extraConfig = ''
        set -g set-titles on
        set -g set-titles-string "#I:#P - #W - #T"
        set -g update-environment "SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION"
        bind s split-window -v
        bind v split-window -h
        set -g automatic-rename on
        set -g allow-passthrough on
        set-option -sa terminal-overrides ',alacritty:RGB'
      '';
    };

    services.flameshot.enable = true;

    home.stateVersion = "24.11";
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
    wireshark.enable = true;
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
        i3lock
        i3blocks
        i3status
      ];
    };
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "andrer";

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
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
