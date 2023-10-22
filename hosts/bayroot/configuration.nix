{ lib, ... }:

{
  networking.hostName = "bayroot";

  imports = [
    ./hardware-configuration.nix
    ../../nixos/services/nebula
  ];

  boot.loader.systemd-boot.configurationLimit = 5;  # small-ish /boot
  boot.loader.systemd-boot.enable = true;
  boot.kernelParams = [ "console=ttyS0" ];

  time.timeZone = "Europe/Prague";

  networking.useDHCP = false;
  services.cloud-init = {
    enable = true;
    network.enable = true;
    settings = {
      cloud_init_modules = lib.mkForce [];
      cloud_config_modules = lib.mkForce [];
      cloud_final_modules = lib.mkForce [];
    };
  };

  zramSwap = { enable = true; memoryPercent = 50; };

  users.mutableUsers = false;
  users.users.monk.hashedPasswordFile = "/mnt/persist/secrets/login/monk";
  users.users.root.hashedPasswordFile = "/mnt/persist/secrets/login/root";

  system.noGraphics = true;
  home-manager.users.monk.system.noGraphics = true;

  system.stateVersion = "23.11";
  home-manager.users.monk.home.stateVersion = "23.11";

  environment.persistence."/mnt/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/nixos"
      "/var/log"
    ];
    files =
      let
        mode = { mode = "0755"; };
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
