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

  #boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
    pulseaudio.enable = false; # Use Pipewire, the modern sound subsystem
  };

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/home".options = [ "noatime" "nodiratime" "discard" ];

  virtualisation.hypervGuest.enable = true;

  networking.hostName = "nixtest"; # Define your hostname.
  networking.wireless.enable = false;
  # Workaround for strange Docker issues with dhcp active on bridge network. See: https://github.com/NixOS/nixpkgs/issues/109389
  networking.dhcpcd.denyInterfaces = [ "veth*" ];
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
    acpid
    alacritty
    bat
    bc
    binutils
    bluez
    bluez-tools
    btop
    colordiff
    cpufetch # Terminal CPU info
    croc # Terminal file transfer
    curl
    curlie # Terminal HTTP client
    dconf
    direnv
    docker_28
    docker-compose
    dos2unix
    dunst
    keychain
    dxvk # Direct3D 9/10/11 to Vulkan translation (Wine/Proton)
    exfat # Read/write exFAT (for USB drives/cameras)
    ffmpeg-full # Complete FFmpeg suite for audio/video encoding, decoding, transcoding, and streaming
    file # Terminal file info
    flameshot
    frogmouth # Terminal markdown viewer
    fzf
    ghostty
    girouette # Modern Unix weather
    git
    glow # Terminal Markdown viewer
    gst_all_1.gst-libav # GStreamer plugin wrapping FFmpeg/libav for broad codec support
    gst_all_1.gst-plugins-bad # Experimental or less maintained plugins, still open-source (e.g. newer formats)
    gst_all_1.gst-plugins-base # Core set of essential GStreamer plugins (e.g. Ogg, Theora, Vorbis)
    gst_all_1.gst-plugins-good # Well-supported plugins under good licensing (e.g. Matroska, FLAC, RTP)
    gst_all_1.gst-plugins-ugly # Plugins with potential licensing or patent issues (e.g. MP3, MPEG-2)
    gst_all_1.gst-vaapi # Plugin enabling VA-API hardware-accelerated video encoding/decoding
    htop # Interactive system monitor (like a better 'top')
    httpie # Terminal HTTP client
    imagemagick # Powerful image manipulation tool (for converting, resizing, and editing images)
    inotify-tools
    iptables
    jq
    killall # Stop running processes by name
    libaom # AOMedia Video 1 (AV1) codec library
    libexif # EXIF metadata support (extract metadata like camera info and timestamps)
    libjpeg # JPEG image support (commonly used format)
    libnotify
    libpng # PNG image support (including transparent images)
    libraw # RAW image format support (for images from digital cameras)
    libtheora # Theora video compression codec (open VP3 implementation)
    libtiff # TIFF format support (used for high-quality images and scanning)
    libvpx # VP8/VP9 video codec library from Google
    libwebp # WebP format support (modern image format, often used on websites)
    linux-firmware
    litecli
    lm_sensors # Read CPU temperatures, fan speeds, voltages, etc.
    logrotate # Required for rotating logs and automatic updates
    lshw
    lxappearance
    man-pages # Man pages for command-line tools
    marp-cli # Terminal Markdown presenter
    mc
    mesa-demos
    most
    mpv # Backend for SMPlayer.
    mtr # Modern Unix `traceroute`
    ncdu
    nemo-with-extensions
    nftables
    nixpkgs-fmt
    ntfs3g # Read/write NTFS (Windows) drives
    openjpeg # JPEG 2000 format support (used in some PDFs, publishing, and archival)
    optipng # Terminal PNG optimizer
    pamixer
    pavucontrol
    pciutils # `lspci` — list PCI devices (e.g., GPUs, Wi-Fi cards)
    pulseaudioFull
    remmina
    rsync
    rtkit
    smplayer # A more feature-rich media player with the mpv backend, offering advanced controls and customization.
    speedtest-go # Terminal speedtest.net
    sqlite
    teams-for-linux
    tldr
    tmux
    tree
    udiskie
    udisks
    unrar
    unzip
    usbutils # `lsusb` — list USB devices
    vim-full
    vmware-horizon-client
    watch
    wget # Download files from the web (handy for scripts or terminal use)
    which
    wormhole-william # Terminal file transfer
    x264 # H.264/MPEG-4 AVC video encoder
    x265 # H.265/HEVC video encoder
    xclip
    xdg-utils # Desktop environment integration (e.g., `xdg-open`)
    xorg.xdpyinfo
    xsel
    xss-lock
  ];

  fonts.enableDefaultPackages = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "wireshark" "docker" "kvm" ];
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
          gtk-application-prefer-dark-theme=true
          gtk-font-name="FiraCode Nerd, 10"
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
      MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = "-c";
      PAGER = "bat";
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

    programs.dircolors = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batwatch
        prettybat
      ];
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
      initExtra = ''
        if command -v keychain > /dev/null 2>&1; then eval $(keychain --eval --nogui id_rsa  --quiet); fi
      '';
      shellAliases = {
        ll = "ls --color=auto -lha";
        myextip = "curl ipinfo.io/ip";
        grep = "grep --color=auto";
        mv = "mv -i";
        cp = "cp -i";
        ln = "ln -i";
        dmesg = "dmesg --human --color=always";
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

    home.stateVersion = "24.11";
  };

  programs = {
    mtr.enable = true;
    dconf.enable = true;
    wireshark.enable = true;
    ssh.startAgent = true;
  };

  services.acpid.enable = true;
  services.fstrim.enable = true;
  services.tlp.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    #openFirewall = true;
  };
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.udisks2.enable = true;

  services.pipewire = {
    enable = true;
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

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_28;
    daemon.settings = {
      userland-proxy = false;
    };
  };

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  networking.nftables.enable = false;
  networking.firewall = {
    enable = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
