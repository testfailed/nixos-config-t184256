{ pkgs, ... }:

{
  networking.hostName = "duckweed";

  imports = [
    ./hardware-configuration.nix
    ../../nixos/services/dns.nix
    ../../nixos/services/syncthing-relay.nix
  ];

  boot.loader.systemd-boot.enable = true;
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A2EB-3AB7";
    fsType = "vfat";
    options = [ "nofail" ];
  };
  boot.kernelParams = [ "console=ttyS0" ];

  nix.autoOptimiseStore = true;  # it's tight on disk space

  users.mutableUsers = false;
  users.users.monk.passwordFile = "/mnt/persist/passwords/monk";
  users.users.root.passwordFile = "/mnt/persist/passwords/root";

  system.noGraphics = true;
  home-manager.users.monk.system.noGraphics = true;

  system.stateVersion = "21.05";
  home-manager.users.monk.home.stateVersion = "21.05";

  environment.persistence."/mnt/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/private/syncthing-relay"
      "/var/log"
    ];
    files =
      let
        mode = { mode = "0700"; };
      in
      [
        "/etc/machine-id"
        { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = mode; }
        { file = "/etc/ssh/ssh_host_rsa_key.pub"; parentDirectory = mode; }
        { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = mode; }
        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = mode; }
      ];
    users.monk = {
      directories = [
        ".local/share/pygments-cache"
        ".local/share/xonsh"
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
