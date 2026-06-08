# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  #boot.initrd = {
  #  luks.devices = {
  #    luksCrypted = {
  #      device = "/dev/disk/by-uuid/41c487f2-f414-43f2-be0b-b0590f069bdf"; # Replace with your UUID
  #      preLVM = true; # Unlock before activating LVM
  #      allowDiscards = true; # Allow TRIM commands for SSDs
  #    };
  #  };
  #  checkJournalingFS = false;
  #};

  boot.initrd.luks.devices."luks-41c487f2-f414-43f2-be0b-b0590f069bdf".device =
    "/dev/disk/by-uuid/41c487f2-f414-43f2-be0b-b0590f069bdf";

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

  # The Linux kernel to use
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Delete all files in /tmp during boot
  boot.tmp.cleanOnBoot = true;

  # quite - Don't show terminal output unless an error occurs
  # splash - Show splash screen theme (if available)
  # pti on/off - Enable/disable Page Table Isolation (PTI).
  #              Protects from attacks on the shared user/kernel address space,
  #              but with a cost of a little perfomance overhead
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  boot.kernel.sysctl = {
    "kernel.dmesg_restrict" = 1; # Restrict access to kernel logs for non-root users (for security)
    # Needed for running SAP in Docker
    "fs.file-max" = 20000000; # Maximum number of open file descriptors (for applications that require many files, e.g., databases, web servers)
    "fs.aio-max-nr" = 4194304; # Maximum number of allowed concurrent asynchronous I/O operations (for applications that use async I/O, e.g., databases, web servers)
    "vm.max_map_count" = 2147483647; # Maximum number of memory map areas a process may have (for applications that use many memory mappings, e.g., databases, web servers)
    "net.ipv4.tcp_syncookies" = 1;
    "vm.swappiness" = 10;
  };

  # All Kernel Messages with a log level smaller
  # than this setting will be printed to the console
  boot.consoleLogLevel = 3;

  hardware = {
    alsa.enablePersistence = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    firmware = with pkgs; [
      wireless-regdb
    ];
    graphics.enable32Bit = true;
    graphics.enable = true;
    i2c.enable = true;
    sane.enable = true;
  };

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
    "discard"
  ];

  fileSystems."/mnt/scan" = {
    device = "//fritte1.fritz.box/scan";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,forceuid,forcegid";
      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets-scan" ];
  };

  fileSystems."/mnt/backup" = {
    device = "//nas.fritz.box/Backup";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,forceuid,forcegid";
      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets-nas" ];
  };

  fileSystems."/mnt/dokumente" = {
    device = "//nas.fritz.box/Dokumente";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,forceuid,forcegid";
      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets-nas" ];
  };

  fileSystems."/mnt/photo" = {
    device = "//nas.fritz.box/photo";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,forceuid,forcegid";
      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets-nas" ];
  };

  fileSystems."/mnt/video" = {
    device = "//nas.fritz.box/video";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=100,forceuid,forcegid";
      in
      [ "${automount_opts},credentials=/etc/nixos/smb-secrets-nas" ];
  };

  networking.hostName = "tpt470"; # Define your hostname.

  networking.networkmanager.enable = true;

  networking.networkmanager.wifi.powersave = true;

  # Workaround for strange Docker issues with dhcp active on bridge network. See: https://github.com/NixOS/nixpkgs/issues/109389
  networking.dhcpcd.denyInterfaces = [ "veth*" ];

  # Configure NTP time server
  networking.timeServers = options.networking.timeServers.default ++ [ "ptbtime1.ptb.de" ];

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
    colors = [
      "2e3440"
      "bf616a"
      "a3be8c"
      "d08770"
      "81a1c1"
      "b48ead"
      "88c0d0"
      "8fbcbb"
      "3b4252"
      "bf616a"
      "5e81ac"
      "8fbcbb"
      "8fbcbb"
      "434c5e"
      "d8dee9"
      "ebcb8b"
    ]; # blue red green orange light-blue pink cyan? light-pink(turquoise)? polar-night2 deepred teal lessteal purple grey
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
    alsa-tools # ALSA utilities for audio configuration and troubleshooting (e.g., `alsamixer`, `amixer`, `speaker-test`)
    anki
    arandr
    ausweisapp
    autorandr
    azure-cli
    bat
    bc
    binutils
    binwalk # Firmware Analysis Tool
    bitwarden-cli # Secure and free password manager for all of your devices
    blobby # Blobby volleyball game
    bluez
    bluez-tools
    bridge-utils # Userspace tool to configure linux bridges (deprecated in favour or iproute2)
    btop
    camset # GUI for Video4Linux adjustments of webcams
    chawan # Lightweight and featureful terminal web browser
    cifs-utils # Tools for managing Linux CIFS client filesystems
    claude-code # Agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster
    colordiff
    coreutils
    cpufetch # Terminal CPU info
    croc # Terminal file transfer
    curl
    curlie # Terminal HTTP client
    dbeaver-bin
    dconf
    ddcui # Graphical user interface for ddcutil - control monitor settings
    ddcutil # Query and change Linux monitor settings using DDC/CI and USB
    dell-command-configure # Dell Command | Configure CLI tool for managing Dell BIOS settings from Linux
    direnv
    discord # All-in-one cross-platform voice and text chat for gamers
    dnsutils
    docker_29
    docker-buildx
    docker-compose
    dos2unix
    dotnet-sdk_10
    dunst
    dxvk # Direct3D 9/10/11 to Vulkan translation (Wine/Proton)
    elfutils
    ethtool # Utility for controlling network drivers and hardware
    exfatprogs # exFAT filesystem userspace utilities
    fastfetch # Actively maintained, feature-rich and performance oriented, neofetch like system information tool
    feh # Light-weight image viewer
    ffmpeg-full # Complete FFmpeg suite for audio/video encoding, decoding, transcoding, and streaming
    file # Terminal file info
    filezilla
    flameshot
    frogmouth # Terminal markdown viewer
    fzf # Command-line fuzzy finder for files, command history, processes, and more, with interactive preview and multi-select capabilities
    ghostty # Terminal emulator with a focus on performance and simplicity, written in Rust
    gimp3-with-plugins # GNU Image Manipulation Program
    girouette # Modern Unix weather
    gitFull # Version control system for tracking changes in source code during software development
    git-lfs # Git extension for versioning large files (e.g., media assets, datasets) by storing them outside the main repository
    gittyup # Terminal Git client with a focus on simplicity and speed, written in Rust
    gitui # Blazing fast terminal-ui for Git written in Rust
    glow # Terminal Markdown viewer
    gnome-themes-extra
    gnumake # Tool to control the generation of non-source files from sources
    gparted # Graphical disk partitioning tool
    gst_all_1.gst-libav # GStreamer plugin wrapping FFmpeg/libav for broad codec support
    gst_all_1.gst-plugins-bad # Experimental or less maintained plugins, still open-source (e.g. newer formats)
    gst_all_1.gst-plugins-base # Core set of essential GStreamer plugins (e.g. Ogg, Theora, Vorbis)
    gst_all_1.gst-plugins-good # Well-supported plugins under good licensing (e.g. Matroska, FLAC, RTP)
    gst_all_1.gst-plugins-ugly # Plugins with potential licensing or patent issues (e.g. MP3, MPEG-2)
    gst_all_1.gst-vaapi # Plugin enabling VA-API hardware-accelerated video encoding/decoding
    gtk-engine-murrine # Very flexible theme engine
    guvcview # Simple interface for devices supported by the linux UVC driver
    gxmessage # Graphical message box utility for X11, similar to `zenity` or `kdialog`, allowing you to display simple dialog boxes from shell scripts or the command line
    hexedit # View and edit files in hexadecimal or in ASCII
    hextazy # TUI hexeditor in Rust with colored bytes
    htop # Interactive system monitor (like a better 'top')
    httpie # Terminal HTTP client
    hueadm # Terminal Philips Hue client
    hunspell
    hunspellDicts.de_DE
    hyphenDicts.de_DE
    ifuse # optional, to mount using 'ifuse'
    ifwifi # Terminal Wi-Fi manager for NetworkManager, allowing you to connect to and manage Wi-Fi networks from the command line
    illum # Daemon that wires button presses to screen backlight level
    imagemagick # Powerful image manipulation tool (for converting, resizing, and editing images)
    imhex # Hex Editor for Reverse Engineers, Programmers and people who value their retinas when working at 3 AM
    inetutils # Collection of common network programs
    inotify-tools
    iotop-c # Terminal I/O monitor with a top-like interface, written in C for better performance and lower resource usage compared to the original Python version
    iproute2 # Collection of utilities for controlling TCP/IP networking and traffic control in Linux
    iptables # Program to configure the Linux IP packet filtering ruleset
    javaPackages.compiler.temurin-bin.jdk-21
    joplin-cli # Command-line interface for Joplin, allowing you to manage your notes and notebooks from the terminal, with support for synchronization and encryption
    joplin-desktop # Open-source note-taking and to-do application with markdown support, synchronization, and end-to-end encryption
    jpegoptim # Optimize JPEG files
    jq
    keychain # Manage SSH and GPG keys in a convenient and secure manner
    killall # Stop running processes by name
    libaom # AOMedia Video 1 (AV1) codec library
    libexif # EXIF metadata support (extract metadata like camera info and timestamps)
    libimobiledevice # Library to communicate with iOS devices (for tools like `ideviceinfo` and `idevicesyslog`)
    libjpeg # JPEG image support (commonly used format)
    libnotify
    libpng # PNG image support (including transparent images)
    libraw # RAW image format support (for images from digital cameras)
    libreoffice-still
    librewolf # Fork of Firefox, focused on privacy, security and freedom
    libsecret # Library for storing and retrieving passwords and other secrets (also used by vkbasalt to store shader-repo API keys)
    libtheora # Theora video compression codec (open VP3 implementation)
    libtiff # TIFF format support (used for high-quality images and scanning)
    libv4l # Video4Linux2 (V4L2) library for video capture and output (for webcams)
    libva-utils
    libva # Video Acceleration API (VA-API) for hardware-accelerated video decoding/encoding
    libvirt
    libvpx # VP8/VP9 video codec library from Google
    libwebp # WebP format support (modern image format, often used on websites)
    libx11 # Core X11 protocol client library (aka "Xlib")
    libxext
    libxpm # X Pixmap (XPM) image file format library
    linux-firmware
    litecli # Terminal client for SQLite databases with autocompletion and syntax highlighting
    lm_sensors # Read CPU temperatures, fan speeds, voltages, etc.
    logrotate # Required for rotating logs and automatic updates
    lsd # A modern replacement for 'ls' with a focus on simplicity and color, written in Rust
    lshw # Hardware lister (detailed info about hardware components)
    lxappearance
    maim # Terminal screenshot tool with support for selecting a region, window, or entire screen, and saving to file or clipboard
    man-pages # Man pages for command-line tools
    marp-cli # Terminal Markdown presenter
    mc # Midnight Commander, a powerful terminal file manager with a text user interface
    meld # Visual diff and merge tool
    mesa-demos
    mfcl3770cdwcupswrapper
    mfcl3770cdwlpr # Brother MFCL3770CDW driver
    mjpg-streamer # Takes JPGs from Linux-UVC compatible webcams, filesystem or other input plugins and streams them as M-JPEG via HTTP to webbrowsers, VLC and other software
    most # Terminal pager with advanced features (e.g., multiple windows, horizontal scrolling, mouse support)
    mpv # Backend for SMPlayer.
    msbuild-structured-log-viewer # Terminal viewer for MSBuild structured log files, allowing you to analyze and debug .NET build processes
    mtr # Modern Unix `traceroute`
    mupdf # Lightweight PDF, XPS, and E-book viewer and toolkit written in portable C
    ncdu # Terminal disk usage analyzer with an ncurses interface, allowing you to easily find and manage large files and directories
    nemo-with-extensions
    net-tools # Set of tools for controlling the network subsystem in Linux (ifconfig, netstat, route, etc.)
    networkmanagerapplet # System tray applet for NetworkManager, providing a graphical interface to manage network connections and settings
    nixfmt # Nixfmt is the official formatter for Nix language code
    nixfmt-tree
    nmap # Free and open source utility for network discovery and security auditing
    nodejs_24 # Event-driven I/O framework for the V8 JavaScript engine
    nordic # Nordic GTK theme
    ntfs3g # Read/write NTFS (Windows) drives
    nvtopPackages.full # Real-time GPU monitor (NVIDIA/AMD/Intel)
    obsidian-export # Rust library and CLI to export an Obsidian vault to regular Markdown
    obsidian # Powerful knowledge base that works on top of a local folder of plain text Markdown files
    obs-studio # Powerful open-source software for video recording and live streaming
    ocrmypdf # Adds an OCR text layer to scanned PDF files, allowing them to be searched
    omnissa-horizon-client
    opencode # Terminal code editor with a focus on simplicity and performance, written in Rust
    openjpeg # JPEG 2000 format support (used in some PDFs, publishing, and archival)
    openssl
    optipng # Terminal PNG optimizer
    pamixer
    patchelf
    pavucontrol
    pciutils # `lspci` — list PCI devices (e.g., GPUs, Wi-Fi cards)
    pdfchain
    pdfstudioviewer
    pdftk
    pngoptimizer # PNG optimizer and converter
    poppler-utils # PDF rendering library
    powershell # Powerful cross-platform (Windows, Linux, and macOS) shell and scripting language based on .NET
    powertop # Analyze power consumption on Intel-based laptops
    qbittorrent
    remmina
    rich-cli # Terminal file previewer with support for images, PDFs, markdown, and more, using the rich library for beautiful formatting
    rofi-rbw-x11 # Rofi frontend for Bitwarden
    rpi-imager # Raspberry Pi Imaging Utility
    rsync
    rtkit
    sane-backends
    scite # Lightweight and powerful source code editor with support for many programming languages, syntax highlighting, and extensibility through Lua scripting
    scrcpy # Display and control Android devices connected via USB (or over TCP/IP)
    screenfetch
    #sequoia-sq # Command line application exposing a useful set of OpenPGP functionality for common tasks
    serie # Rich git commit graph in your terminal, like magic
    shellcheck # Shell script analysis tool
    signal-desktop # Private, simple, and secure messenger
    smplayer # A more feature-rich media player with the mpv backend, offering advanced controls and customization.
    speedtest-go # Terminal speedtest.net
    sqlcl # Oracle SQL Developer Command Line
    sqlcmd # Microsoft SQL Server command-line tool
    sqlite # Command-line interface for SQLite databases
    sq # Swiss army knife for data
    sshfs # FUSE-based filesystem that allows remote filesystems to be mounted over SSH
    steam-run # Wrapper to run Steam games on Linux with better compatibility (e.g., using Proton for Windows games)
    tailspin # Log file highlighter
    teams-for-linux
    tesseract # Terminal OCR (Optical Character Recognition) tool to extract text from images, supporting multiple languages and output formats
    testdisk # Data recovery utilities
    thunderbird # Full-featured e-mail client
    tldr
    tmux
    tree
    udiskie
    udisks
    unrar
    unstable.vscode-fhs # Wrapped variant of vscode which launches in a FHS compatible environment, should allow for easy usage of extensions without nix-specific modifications
    unzip
    usbmuxd # Daemon to multiplex connections to iOS devices (for tools like `ideviceinfo` and `idevicesyslog`)
    usbutils # `lsusb` — list USB devices
    util-linux
    v4l-utils # V4L utils and libv4l, provide common image formats regardless of the v4l device (for webcams)
    vde2 # Virtual Distributed Ethernet, an Ethernet compliant virtual network
    vim-full
    virt-manager
    vkbasalt # Vulkan post-processing (e.g., contrast, sharpening)
    vkd3d # Direct3D 12 to Vulkan translation (Wine/Proton)
    vlc
    watch
    webcamoid # Webcam Capture Software
    webex # All-in-one app to call, meet, message, and get work done
    wget # Download files from the web (handy for scripts or terminal use)
    which
    wireshark # Powerful network protocol analyzer
    wormhole-william # Terminal file transfer
    wxhexeditor # Hex Editor / Disk Editor for Huge Files or Devices
    x264 # H.264/MPEG-4 AVC video encoder
    x265 # H.265/HEVC video encoder
    xclip
    xcolor # Lightweight color picker for X11
    xdg-desktop-portal-gtk # Desktop integration portals for sandboxed apps
    xdg-launch # Command line XDG compliant launcher and tools
    xdg-user-dirs # Tool to help manage well known user directories like the desktop folder and the music folder
    xdg-utils # Desktop environment integration (e.g., `xdg-open`)
    xdotool # Command-line X11 automation tool (simulate keyboard input, mouse activity, window management, etc.)
    xdpyinfo
    xf86inputsynaptics # Synaptics touchpad driver for Xorg
    xrandr
    xsel
    xss-lock
    yazi # Blazing fast terminal file manager written in Rust, based on async I/O
    yaziPlugins.chmod # Add a chmod plugin to yazi to change file permissions from the file manager
    yaziPlugins.full-border # Add a full border to yazi for better visibility and aesthetics
    yaziPlugins.git # Show the status of Git file changes as linemode in the file list
    yaziPlugins.gitui # Integrate gitui into yazi to show git status and perform git operations from the file manager
    yaziPlugins.nord # Nord theme for yazi
    yaziPlugins.rich-preview # Add a rich preview plugin to yazi to show file previews (e.g., images, PDFs, markdown) in a side panel
    yaziPlugins.sudo # Allow yazi to ask for sudo password to perform privileged operations (e.g., delete files owned by root)
    yt-dlp # Command-line tool to download videos from YouTube.com and other sites (youtube-dl fork)
    zbar # Terminal barcode reader (supports various 1D and 2D barcode formats, e.g., QR codes)
    zellij # Terminal workspace with batteries included, written in Rust, with support for tabs, splits, plugins, and more
    zenmap # Offical nmap Security Scanner GUI
    (texlive.combine {
      inherit (texlive)
        scheme-medium
        xifthen
        ifmtarg
        framed
        paralist
        titlesec
        dvisvgm
        dvipng
        wrapfig
        amsmath
        ulem
        hyperref
        capt-of
        ;
    })
  ];

  fonts.enableDefaultPackages = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrer = {
    isNormalUser = true;
    description = "André Raabe";
    extraGroups = [
      "audio"
      "dialout" # Allows access to serial ports (e.g., `/dev/ttyS*`, `/dev/ttyUSB*`), which is useful for serial communication and development
      "docker"
      "i2c"
      "input"
      "lp"
      "networkmanager"
      "scanner"
      "vboxusers"
      "video"
      "wheel"
      "wireshark"
    ];
  };

  home-manager.useGlobalPkgs = true;

  # Find options: https://nix-community.github.io/home-manager/options.xhtml
  home-manager.users.andrer =
    { config, pkgs, ... }:
    {
      xdg.desktopEntries.nemo = {
        name = "Nemo";
        exec = "${pkgs.nemo-with-extensions}/bin/nemo";
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = [ "nemo.desktop" ];
          "application/x-gnome-saved-search" = [ "nemo.desktop" ];
          "text/html" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
          "application/epub+zip" = "mupdf.desktop";
          "application/oxps" = "mupdf.desktop";
          "application/pdf" = "mupdf.desktop";
          "application/vnd.ms-xpsdocument" = "mupdf.desktop";
          "application/x-cbz" = "mupdf.desktop";
          "application/x-pdf" = "mupdf.desktop";
        };
      };

      fonts.fontconfig = {
        enable = true;
        defaultFonts.monospace = [
          "Iosevka Nerd Font"
        ];
        hinting = "slight";
        antialiasing = true;
        subpixelRendering = "rgb";
      };

      home.packages = with pkgs; [
        corefonts
        font-awesome_6
        noto-fonts
        nerd-fonts.dejavu-sans-mono
        nerd-fonts.fira-code
        nerd-fonts.iosevka
        nerd-fonts.sauce-code-pro
        nerd-fonts.symbols-only
        nerd-fonts.noto
        nerd-fonts.jetbrains-mono
      ];

      xresources.extraConfig = builtins.readFile (
        pkgs.fetchFromGitHub {
          owner = "nordtheme";
          repo = "xresources";
          rev = "ba3b1b61bf6314abad4055eacef2f7cbea1924fb";
          sha256 = "sha256-vw0lD2XLKhPS1zElNkVOb3zP/Kb4m0VVgOakwoJxj74=";
        }
        + "/src/nord"
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
          "gtk-font-name" = "FiraCode Nerd,10";
        };
        gtk4.theme = null;
      };

      qt = {
        enable = true;
        style.package = pkgs.libsForQt5.qtstyleplugins;
        platformTheme.name = "gtk";
      };

      home.sessionVariables = {
        PROMPT_COMMAND = "history -a";
        MANPAGEA = "sh -c 'col --no-backspaces --spaces | bat --language man --theme Nord'";
        MANROFFOPT = "-c";
        PAGER = "bat --theme Nord";
      };

      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
      };

      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
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
            Cryptomining = true;
            Fingerprinting = true;
            Locked = true;
            Value = true;
          };
        };
        profiles = {
          default = {
            id = 0;
            settings = {
              "accessibility.typeaheadfind.flashBar" = 0;
              "app.normandy.first_run" = false;
              "app.normandy.migrationsApplied" = 12;
              "app.shield.optoutstudies.enabled" = false;
              "browser.aboutConfig.showWarning" = false;
              "browser.contentblocking.category" = "standard";
              "browser.crashReporter.memtest" = false;
              "browser.download.animateNotifications" = false;
              "browser.download.useDownloadDir" = true;
              "browser.ml.chat.enabled" = false;
              "browser.ml.chat.sidebar" = false;
              "browser.ml.enable" = false;
              "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
              "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
              "browser.newtabpage.activity-stream.feeds.smartshortcutsfeed" = false;
              "browser.newtabpage.activity-stream.feeds.telemetry" = false;
              "browser.newtabpage.activity-stream.images.smart" = false;
              "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
              "browser.newtabpage.activity-stream.showSponsored" = false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "browser.newtabpage.activity-stream.system.showSponsored" = false;
              "browser.newtabpage.activity-stream.telemetry" = false;
              "browser.newtabpage.pinned" = "";
              "browser.ping-centre.telemetry" = false;
              "browser.safebrowsing.downloads.enabled" = false;
              "browser.safebrowsing.enabled" = false;
              "browser.safebrowsing.malware.enabled" = false;
              "browser.safebrowsing.phishing.enabled" = false;
              "browser.search.defaultenginename" = "DuckDuckGo";
              "browser.search.geoip.url" = "blank";
              "browser.search.isUS" = false;
              "browser.search.order.1" = "DuckDuckGo";
              "browser.search.region" = "US";
              "browser.shell.checkDefaultBrowser" = false;
              "browser.startup.homepage" = "about:profiles";
              "browser.tabs.animate" = false;
              "browser.tabs.crashReporting.sendReport" = false;
              "browser.tabs.groups.smart.enabled" = false;
              "browser.tabs.groups.smart.searchTopicEnabled" = false;
              "browser.tabs.groups.smart.userEnabled" = false;
              "browser.topsites.contile.enabled" = false;
              "browser.translations.automaticallyPopup" = false;
              "browser.urlbar.autoFill" = false;
              "datareporting.healthreport.uploadEnabled" = false;
              "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
              "distribution.searchplugins.defaultLocale" = "en-US";
              "doh-rollout.balrog-migration-done" = true;
              "doh-rollout.doneFirstRun" = true;
              "dom.battery.enabled" = false;
              "dom.forms.autocomplete.formautofill" = false;
              "extensions.autoDisableScopes" = 0;
              "extensions.formautofill.addresses.enabled" = false;
              "extensions.formautofill.creditCards.enabled" = false;
              "extensions.pocket.enabled" = false;
              "extensions.update.enabled" = false;
              "font.name.monospace.x-western" = "FiraCode Nerd Font";
              "general.useragent.locale" = "en-US";
              "geo.enabled" = false;
              "geo.wifi.uri" = "blank";
              "gfx.webrender.all" = true;
              "gfx.x11-egl.force-enabled" = true;
              "identity.fxaccounts.enabled" = false;
              "keyword.enabled" = true;
              "media.autoplay.default" = 2;
              "media.ffmpeg.vaapi.enabled" = true;
              "media.gmp-widevinecdm.enabled" = true;
              "media.hardware-video-decoding.force-enabled" = true;
              "media.peerconnection.ice.no_host" = false;
              "media.rdd-ffmpeg.enabled" = true;
              "media.videocontrols.picture-in-picture.video-toggle.has-used" = true;
              "network.dns.disablePrefetch" = true;
              "network.http.speculative-parallel-limit" = 0;
              "network.predictor.enabled" = false;
              "network.prefetch-next" = false;
              "network.trr.mode" = 5;
              "network.trr.uri" = "";
              "pdfjs.enableScripting" = false;
              "plugins.enumerable_names" = "blank";
              "privacy.donottrackheader.enabled" = true;
              "privacy.purge_trackers.date_in_cookie_database" = 0;
              "privacy.resistFingerprinting" = false;
              "privacy.resistFingerprinting.letterboxing" = false;
              "privacy.sanitize.pending" = "[{'id':'newtab-container','itemsToClear':[],'options':{}}]";
              "privacy.trackingprotection.enabled" = true;
              "privacy.trackingprotection.socialtracking.enabled" = true;
              "signon.rememberSignons" = false;
              "toolkit.telemetry.archive.enabled" = false;
              "toolkit.telemetry.bhrPing.enabled" = false;
              "toolkit.telemetry.enabled" = false;
              "toolkit.telemetry.firstShutdownPing.enabled" = false;
              "toolkit.telemetry.hybridContent.enabled" = false;
              "toolkit.telemetry.newProfilePing.enabled" = false;
              "toolkit.telemetry.reportingpolicy.firstRun" = false;
              "toolkit.telemetry.shutdownPingSender.enabled" = false;
              "toolkit.telemetry.unified" = false;
              "toolkit.telemetry.updatePing.enabled" = false;
              "widget.disable-workspace-management" = true;
              "widget.dmabuf.force-enabled" = true;
            };
            extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
              bitwarden
              languagetool
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
        theme = "nord";
        settings = {
          font = {
            size = 7.0;
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

      programs.ghostty = {
        enableBashIntegration = true;
        enableFishIntegration = false;

        settings = {
          font-size = 10;
          bold-is-bright = true;
          shell-integration = "none";
        };
      };

      programs.rofi = {
        enable = true;
        font = "Iosevka Nerd Font 10";
        location = "center";
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
        historyControl = [
          "ignoreboth"
          "erasedups"
        ];
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
          HISTTIMEFORMAT="(%d.%m.%y) "
          # Workaround for nix-shell --pure
          if [ "$IN_NIX_SHELL" == "pure" ]; then
              if [ -x "$HOME/.nix-profile/bin/powerline-go" ]; then
                  alias powerline-go="$HOME/.nix-profile/bin/powerline-go"
              elif [ -x "/run/current-system/sw/bin/powerline-go" ]; then
                  alias powerline-go="/run/current-system/sw/bin/powerline-go"
              fi
          fi

          # include .bashrc_local if it exists
          [[ -f ~/.bashrc_local ]] && . ~/.bashrc_local
        '';
        initExtra = ''
          if command -v keychain > /dev/null 2>&1; then eval $(keychain --eval --nogui id_rsa --quiet); fi
          if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
            export TERM=xterm-256color
          fi
        '';
        shellAliases = {
          cp = "cp -iv";
          diff = "colordiff";
          grep = "grep --color=auto";
          dmesg = "sudo dmesg --human --color=always";
          ll = "ls --color=auto -lha";
          ln = "ln -iv";
          # Latest version can be build with: docker build -t lazyteam/lazydocker https://github.com/jesseduffield/lazydocker.git
          lzd = "docker run --rm -it --name lazydocker -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.config/lazydocker:/.config/jesseduffield/lazydocker lazyteam/lazydocker";
          mv = "mv -iv";
          myextip = "curl ipinfo.io/ip";
          rm = "rm -iv";
          docker-ips = "docker inspect \$(docker ps -q) | jq -r '.[] | \"\(.Name | ltrimstr(\"/\")) - \(.NetworkSettings.Networks | to_entries[] | .value.IPAddress)\"'";
        };
        shellOptions = [
          "histappend"
          "extglob"
          "globstar"
          "checkjobs"
          "checkwinsize"
        ];
      };

      programs.git = {
        enable = true;
        lfs.enable = true;
        settings = {
          alias = {
            lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
            graph = "log --decorate --oneline --graph";
          };
          branch.autosetuprebase = "always";
          color.ui = true;
          core.askPass = ""; # needs to be empty to use terminal for ask pass
          fetch.showForcedUpdates = true;
          github.user = "akaer";
          merge.tool = "meld";
          user.email = "andre.raabe@gmail.com";
          user.name = "André Raabe";
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          syntax-theme = "Nord";
          minus-style = "#fdf6e3 #dc322f";
          plus-style = "#fdf6e3 #859900";
          side-by-side = false;
        };
      };

      programs.readline = {
        enable = true;
        extraConfig = ''
          # Show tab-completion options on first <tab> instead of waiting
          # for multiple completions.
          set show-all-if-ambiguous on

          # Case insensitive tab-completion
          set completion-ignore-case on

          $if Bash
            # In bash only, enable "magic space" so that typing space
            # will show completions. i.e. !!_ (where _ is space)
            # will expand !! for you.
            Space: magic-space
          $endif
        '';
      };

      programs.vim = {
        enable = true;
        settings = {
          number = true;
        };
        # Search plugins: nix-env -f '<nixpkgs>' -qaP -A vimPlugins
        plugins = with pkgs.vimPlugins; [
          command-t
          nerdtree
          nord-vim
          supertab
          syntastic
          vim-airline
          vim-airline-themes
          vim-fugitive
          vim-sensible
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

          " Set encoding
          set encoding=utf-8

          " Disable Backup and Swap files
          set noswapfile
          set nobackup
          set nowritebackup

          set list listchars=tab:»·,trail:·
          " Disable Mode Display because Status line is on
          set noshowmode

          " Strip trailing whitespaces on each save
          fun! <SID>StripTrailingWhitespaces()
            let l = line(".")
            let c = col(".")
            %s/\s\+$//e
            call cursor(l, c)
          endfun
          autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

          " Close window if last remaining window is NerdTree
          autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

          " Disable code folding
          set nofoldenable

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
        terminal = "xterm-256color";
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
          set -g update-environment "SSH_ASKPASS SSH_AUTH_SOCK SSH_AGENT_PID SSH_CONNECTION DISPLAY"
          # split panes using | and -
          bind | split-window -h
          bind - split-window -v
          unbind '"'
          unbind %
          # don't rename windows automatically
          set-option -g allow-rename off
        '';
      };

      programs.autorandr = {
        enable = true;
        profiles = {
          "notebook" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff0006af3d2400000000001a0104951f117802a2b591575894281c505400000001010101010101010101010101010101843a8034713828403064310035ad10000018d02e8034713828403064310035ad10000018000000fe0041554f0a202020202020202020000000fe004231343048414e30322e34200a00e4";
            };
            config = {
              eDP-1 = {
                enable = true;
                primary = true;
                mode = "1920x1080";
                rate = "60.03";
                position = "0x0";
                filter = "nearest";
              };
            };
          };
          "arbeitszimmer" = {
            fingerprint = {
              eDP-1 = "00ffffffffffff0006af3d2400000000001a0104951f117802a2b591575894281c505400000001010101010101010101010101010101843a8034713828403064310035ad10000018d02e8034713828403064310035ad10000018000000fe0041554f0a202020202020202020000000fe004231343048414e30322e34200a00e4";
              DP-1 = "00ffffffffffff0004720705c1280000101d0103804627782aa0b59d5952a0260d5054bfef808180e1c0d1c0a940b300d100a9c081c0565e00a0a0a0295030203500bb892100001a000000ff005447434545303031335030300a000000fd00174c0f5a1e000a202020202020000000fc0045423332314851550a202020200116020327f052100504030207061f14131211161520212201230907078301000067030c0010001042023a801871382d40582c4500bb892100001e011d8018711c1620582c2500bb892100009e011d007251d01e206e285500bb892100001e8c0ad08a20e02d10103e9600bb89210000180000000000000000000000000000000093";
            };
            config = {
              eDP-1 = {
                enable = true;
                primary = false;
                mode = "1920x1080";
                rate = "60.03";
                position = "2560x0";
              };
              DP-1 = {
                enable = true;
                primary = true;
                mode = "2560x1440";
                rate = "59.95";
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
            icons = "awesome6";
            theme = "nord-dark";
            blocks = [
              {
                block = "net";
                device = "wlp4s0";
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

          # Clipboard manager clipcat
          set $launcher-clipboard-insert clipcat-menu insert
          bindsym Mod4+p exec $launcher-clipboard-insert

          # Screenshot with flameshot
          bindsym Print exec flameshot gui -d 2000

          # Read bar or qr codes
          bindsym Mod4+q exec maim -qs | zbarimg -q --raw - | xclip -selection clipboard -f

          # OCR
          bindsym Mod4+o exec flameshot gui -s -r | tesseract - - | gxmessage -title "Decoded Data" -fn "Consolas 12" -wrap -geometry 640x480 -file -
        '';
        config = {
          modifier = "Mod4";
          fonts = {
            names = [ "Iosevka Nerd Font" ];
            style = "Regular";
            size = 8.0;
          };
          startup = [
            {
              command = "flameshot";
              notification = false;
            }
            {
              command = "xss-lock --transfer-sleep-lock -- i3lock --nofork -e -f -c 03062C";
              notification = false;
            }
            {
              command = "nm-applet";
              notification = false;
            }
            {
              command = "blueman-applet";
              notification = false;
            }
          ];
          menu = "\"rofi -modi window,drun,run,ssh,calc -icon-theme 'Papirus-Nord' -show-icons -show drun -sidebar-mode -terminal i3-sensible-terminal -theme 'Arc-Dark'\"";
          keybindings = lib.mkOptionDefault {
            "Mod4+Shift+e" = "mode \"$mode_system\"";
          };
          bars = [
            {
              position = "top";
              fonts = {
                names = [
                  "Iosevka Nerd Font"
                  "Font Awesome 5 Free"
                ];
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

      services.clipcat = {
        enable = true;
        daemonSettings = {
          daemonize = true;
          max_history = 150;
        };
        ctlSettings = {
          server_endpoint = "/run/user/1000/clipcat/grpc.sock";
          log = {
            file_path = "/tmp/clipcatctl.log";
            emit_journald = true;
            emit_stdout = false;
            emit_stderr = false;
            level = "INFO";
          };
        };
        menuSettings = {
          server_endpoint = "/run/user/1000/clipcat/grpc.sock";
          finder = "rofi";
          rofi = {
            line_length = 100;
            menu_length = 30;
            menu_prompt = "Clipcat";
            extra_arguments = [
              "-mesg"
              "Please select a clip"
              "-theme"
              "Arc-Dark"
            ];
          };
        };
      };

      services.flameshot.enable = true;
      services.remmina.enable = true;
      services.remmina.addRdpMimeTypeAssoc = true;
      services.remmina.systemdService.enable = true;
      services.autorandr.enable = true;
      services.autorandr.ignoreLid = true;

      home.stateVersion = "26.05";
    };

  programs = {
    dconf.enable = true;
    i3lock.enable = true;
    mtr.enable = true;
    nix-ld.enable = true;
    ssh.startAgent = true;
  };

  powerManagement.powertop.enable = false;

  services.acpid.enable = true;
  services.blueman.enable = true;
  services.usbmuxd.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    openFirewall = true;
  };
  services.dbus.enable = true;
  services.dbus.packages = [ pkgs.dconf ];
  services.gvfs.enable = true;
  services.illum.enable = true;
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      GatewayPorts = "yes";
      X11Forwarding = true;
      UseDns = false;
    };
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

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
      options = "eurosign:e,terminate:ctrl_alt_bksp";
    };
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
    package = pkgs.docker_29;
    logDriver = "json-file";
    daemon.settings = {
      ipv6 = true;
      experimental = true;
      userland-proxy = false;
      features.cdi = true;
      data-root = "/home/docker";
      log-opts = {
        "max-size" = "10m";
        "max-file" = "3";
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  environment.variables = {
    EDITOR = "vim";
    TERMINAL = "alacritty";
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";
    NIXPKGS_ALLOW_UNFREE = 1;
    GTK_THEME = "Nordic";
    # Better font rendering in Java applications.
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    # Privacy
    DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    DOTNET_EnableDiagnostics = 0;
    DOTNET_TELEMETRY_OPTOUT = 1;
    POWERSHELL_CLI_TELEMETRY_OPTOUT = 1;
    POWERSHELL_TELEMETRY_OPTOUT = 1;
    POWERSHELL_UPDATECHECK = "Off";
    POWERSHELL_UPDATECHECK_OPTOUT = 1;
    DOTNET_NOLOGO = "true";
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = false;
    #trustedInterfaces = [ "br+" ];
    #allowedTCPPorts = [ 8001 8002 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
