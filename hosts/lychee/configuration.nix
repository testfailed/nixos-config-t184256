{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./onemix-keyboard-remap.nix
  ];


  boot.kernelPackages = pkgs.linuxPackages_5_12;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;  # small /boot
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lychee"; # Define your hostname.
  networking.networkmanager.enable = true;
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox-wayland
    alacritty
  ];
  services.openssh.enable = true;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  users.users.monk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };



  system.stateVersion = "21.05";
  home-manager.users.monk.home.stateVersion = "21.05";
}
