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

  boot.blacklistedKernelModules = [ "nouveau" ];

  boot.kernelPackages = pkgs.linuxPackages;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
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
      open_wifi_stealing_ur_datas = { };
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
    arandr
    autorandr
    bat
    bc
    binutils
    bluez
    bluez-tools
    btop
    colordiff
    curl
    dconf
    direnv
    docker
    docker-compose
    dunst
    file
    flameshot
    fzf
    ghostty
    git
    glow
    htop
    inotify-tools
    iptables
    jq
    killall
    libnotify
    linux-firmware
    litecli
    lshw
    lxappearance
    mc
    most
    ncdu
    nemo-with-extensions
    nftables
    nixpkgs-fmt
    pamixer
    pavucontrol
    pciutils
    pulseaudioFull
    remmina
    sqlite
    teams-for-linux
    tldr
    tmux
    tree
    udisks
    unrar
    unzip
    usbutils
    vim-full
    vmware-horizon-client
    watch
    wget
    which
    xclip
    xorg.xdpyinfo
    xorg.xrandr
    xsel
    xss-lock
  ];

  fonts.enableDefaultPackages = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "wireshark" "docker" ];
    packages = with pkgs; [ ];
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Find options: https://nix-community.github.io/home-manager/options.xhtml
  home-manager.users.andrer = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    xdg.desktopEntries.nemo = {
      name = "Nemo";
      exec = "${pkgs.nemo-with-extensions}/bin/nemo";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "nemo.desktop" ];
        "application/x-gnome-saved-search" = [ "nemo.desktop" ];
      };
    };

    dconf = {
      settings = {
        "org/cinnamon/desktop/applications/terminal" = {
          exec = "alacritty";
          # exec-arg = ""; # argument
        };
      };
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [
        "Iosevka Nerd Font"
      ];
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

    gtk = {
      enable = true;
      theme.name = "Nordic";
      gtk2 = {
        extraConfig = ''
          gtk-application-prefer-dark-theme=true;
          gtk-font-name="FiraCode Nerd, 10";
        '';
      };
      gtk3 = {
        extraCss = ''
          VteTerminal, vte-terminal {
            padding: 30px;
          }
        '';
        extraConfig = {
          "gtk-application-prefer-dark-theme" = true;
          "gtk-font-name" = "FiraCode Nerd, 10";
        };
      };
      gtk4.extraConfig = {
        "gtk-application-prefer-dark-theme" = true;
        "gtk-font-name" = "FiraCode Nerd, 10";
      };
    };

    qt = {
      enable = true;
      style.package = pkgs.libsForQt5.qtstyleplugins;
      platformTheme = "gtk";
    };

    home.sessionVariables = {
      PROMPT_COMMAND = "history -a";
    };

    home.packages = with pkgs; [
      corefonts
      font-awesome
      font-awesome_5
      font-awesome_4
      nordic
      scrcpy
      vscode
      vlc
      mpv
      (pkgs.nerdfonts.override {
        fonts = [
          "Iosevka"
          "FiraCode"
          "DejaVuSansMono"
          "NerdFontsSymbolsOnly"
          "SourceCodePro"
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
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
      profiles = {
        default = {
          id = 0;
          settings = {
            "browser.aboutConfig.showWarning" = false;
            "browser.contentblocking.category" = "standard";
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
            "browser.newtabpage.pinned" = "";
            "browser.search.defaultenginename" = "DuckDuckGo";
            "browser.search.isUS" = false;
            "browser.search.order.1" = "DuckDuckGo";
            "browser.search.region" = "US";
            "browser.startup.homepage" = "about:home";
            "browser.topsites.contile.enabled" = false;
            "browser.translations.automaticallyPopup" = false;
            "distribution.searchplugins.defaultLocale" = "en-US";
            "doh-rollout.balrog-migration-done" = true;
            "doh-rollout.doneFirstRun" = true;
            "dom.forms.autocomplete.formautofill" = false;
            "extensions.autoDisableScopes" = 0;
            "extensions.update.enabled" = false;
            "general.useragent.locale" = "en-US";
            "privacy.donottrackheader.enabled" = true;
            "widget.disable-workspace-management" = true;
          };
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            darkreader
            foxyproxy-standard
            i-dont-care-about-cookies
            languagetool
            link-cleaner
            linkding-extension
            privacy-badger
            theme-nord-polar-night
            ublock-origin
          ];
        };
      };
    };

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

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
      font = "Iosevka Nerd Font 12";
      location = "center";
      theme = "Arc-Dark";
      plugins = [
        pkgs.rofi-calc
        pkgs.rofi-emoji
        pkgs.rofi-bluetooth
        pkgs.rofi-power-menu
      ];
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
      defaultOptions = [ "--color 16" ];
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
      delta = {
        enable = true;
        options = {
          syntax-theme = "Nord";
          minus-style = "#fdf6e3 #dc322f";
          plus-style = "#fdf6e3 #859900";
          side-by-side = false;
        };
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
      aggressiveResize = true;
      historyLimit = 100000;
      resizeAmount = 5;
      escapeTime = 0;

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
        set -g update-environment "SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION DISPLAY"
        bind s split-window -v
        bind v split-window -h
        set -g automatic-rename on
        set -g allow-passthrough on
        set-option -sa terminal-overrides ',alacritty:RGB'
      '';
    };

    programs.autorandr = {
      enable = true;
      profiles = {
        "notebook" = {
          fingerprint = {
            eDP-1 = "00ffffffffffff004c836441000000000b1f0104b5221678020cf1ae523cb9230c50540000000101010101010101010101010101010171df0050f06020902008880058d71000001b71df0050f06020902008880058d71000001b000000fe0044334b4a468031363059563033000000000003040300010000000b010a202001f802030f00e3058000e606050174600700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7";
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = true;
              mode = "1920x1200";
              rate = "60.0";
              position = "0x0";
              filter = "nearest";
            };
          };
        };
        "arbeitszimmer" = {
          fingerprint = {
            eDP-1 = "00ffffffffffff004c836441000000000b1f0104b5221678020cf1ae523cb9230c50540000000101010101010101010101010101010171df0050f06020902008880058d71000001b71df0050f06020902008880058d71000001b000000fe0044334b4a468031363059563033000000000003040300010000000b010a202001f802030f00e3058000e606050174600700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b7";
            DP-4 = "00ffffffffffff0004720705c1280000101d0103804627782aa0b59d5952a0260d5054bfef808180e1c0d1c0a940b300d100a9c081c0565e00a0a0a0295030203500bb892100001a000000ff005447434545303031335030300a000000fd00174c0f5a1e000a202020202020000000fc0045423332314851550a202020200116020327f052100504030207061f14131211161520212201230907078301000067030c0010001042023a801871382d40582c4500bb892100001e011d8018711c1620582c2500bb892100009e011d007251d01e206e285500bb892100001e8c0ad08a20e02d10103e9600bb89210000180000000000000000000000000000000093";
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = false;
              mode = "1920x1200";
              rate = "60.0";
              position = "2560x0";
            };
            DP-4 = {
              enable = true;
              primary = true;
              mode = "2560x1440";
              rate = "60.0";
              position = "0x0";
            };
          };
        };
      };
    };

    programs.i3status-rust = {
      enable = true;
      bars = {
        top = {
          icons = "awesome5";
          theme = "nord-dark";
          blocks = [
            {
              block = "net";
              device = "wlp0s20f3";
              interval = 5;
            }
            {
              block = "cpu";
              format = " $icon $utilization ";
              format_alt = " $icon $frequency{ $boost|} ";
              interval = 3;
            }
            {
              block = "load";
              format = " $icon $1m ";
              interval = 1;
            }
            {
              block = "memory";
              format = " $icon $mem_total_used_percents.eng(w:2)";
              format_alt = " $icon_swap $swap_used_percents.eng(w:2) ";
            }
            {
              block = "disk_space";
              path = "/";
              alert = 10.0;
              warning = 20.0;
              info_type = "available";
              alert_unit = "GB";
              interval = 60;
              format = " $icon  /: $available.eng(w:2)";
            }
            {
              block = "disk_space";
              path = "/home";
              alert = 10.0;
              warning = 20.0;
              info_type = "available";
              alert_unit = "GB";
              interval = 60;
              format = " $icon  /home: $available.eng(w:2)";
            }
            {
              block = "sound";
              click = [
                {
                  button = "left";
                  cmd = "pavucontrol";
                }
              ];
            }
            {
              block = "battery";
              format = " $icon  $percentage ";
            }
            {
              block = "time";
              interval = 60;
              format = "$icon  $timestamp.datetime(f:'%a %d.%m.%Y (CW: %U) %H:%M') ";
            }
          ];
        };
      };
    };

    # https://nix-community.github.io/home-manager/options.xhtml#opt-xsession.windowManager.i3.enable
    xsession.windowManager.i3 = {
      enable = true;
      extraConfig = ''
        set $mode_system System (l) lock, (e) logout, (s) suspend, (r) reboot, (Shift+s) shutdown
        mode "$mode_system" {
          bindsym l exec --no-startup-id loginctl lock-session, mode "default"
          bindsym e exec --no-startup-id i3-msg exit, mode "default"
          bindsym s exec --no-startup-id loginctl lock-session && systemctl suspend, mode "default"
          bindsym r exec --no-startup-id systemctl reboot, mode "default"
          bindsym Shift+s exec --no-startup-id systemctl poweroff -i, mode "default"

          # back to normal: Enter or Escape
          bindsym Return mode "default"
          bindsym Escape mode "default"
        }
      '';
      config = {
        modifier = "Mod4";
        fonts = {
          names = [ "Iosevka Nerd Font" ];
          style = "Regular";
          size = 8.0;
        };
        startup = [
          { command = "flameshot"; notification = false; }
          { command = "xss-lock --transfer-sleep-lock -- i3lock --nofork -e -f -c 03062C"; notification = false; }
        ];
        menu = "\"rofi -modi window,drun,run,calc -icon-theme 'Papirus-Nord' -show-icons -show drun -sidebar-mode -terminal i3-sensible-terminal\"";
        keybindings = lib.mkOptionDefault {
          "Mod4+Shift+e" = "mode \"$mode_system\"";
        };
        bars = [
          {
            position = "top";
            fonts = {
              names = [ "Iosevka Nerd Font" "Font Awesome 5 Free" ];
              style = "Regular";
              size = 10.0;
            };
            trayOutput = "primary";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-top.toml";
          }
        ];
      };
    };

    services.dunst = {
      enable = true;
      iconTheme = {
        name = "papirus-nord";
        package = pkgs.papirus-nord;
      };
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;
          frame_color = "#eceff1";
          font = "Iosevka Nerd Font 9";
        };

        urgency_low = {
          background = "#2E3440";
          foreground = "#D8DEE9";
          timeout = 10;
        };

        urgency_normal = {
          background = "#2E3440";
          foreground = "#D8DEE9";
          timeout = 10;
        };

        urgency_critical = {
          background = "#2E3440";
          foreground = "#D8DEE9";
          frame_color = "#BF616A";
          timeout = 20;
        };

      };
    };

    services.udiskie = {
      enable = true;
      automount = true;
      notify = true;
      tray = "always";
      settings = {
        program_options = {
          file_manager = "${pkgs.nemo-with-extensions}/bin/nemo";
        };
      };
    };

    services.flameshot.enable = true;
    services.remmina.enable = true;
    services.remmina.addRdpMimeTypeAssoc = true;
    services.remmina.systemdService.enable = true;
    services.autorandr.enable = true;
    services.autorandr.ignoreLid = true;

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

  services.acpid.enable = true;
  services.fstrim.enable = true;
  services.tlp.enable = true;
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.printing.enable = true;
  services.udisks2.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

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
        rofi
        papirus-nord
        i3lock
        i3blocks
        i3status-rust
      ];
    };
    displayManager.lightdm = {
      enable = true;
      greeters.gtk = {
        enable = true;
        theme.package = pkgs.nordic;
        theme.name = "Nordic";
      };
      extraConfig = ''
        logind-check-graphical=true
      '';
    };
  };
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "andrer";
  services.displayManager.logToFile = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    allowPing = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
