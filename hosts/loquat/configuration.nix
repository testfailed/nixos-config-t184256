{ ... }:

{
  networking.hostName = "loquat";

  imports = [
    ./hardware-configuration.nix
    ../../nixos/services/dns.nix
    ../../nixos/services/git.nix
    ../../nixos/services/hydra.nix
    ../../nixos/services/mail.nix
    ../../nixos/services/nix-on-droid.nix
    ../../nixos/services/xmpp.nix
  ];

  boot.loader.grub = { enable = true; version = 2; device = "/dev/sda"; };

  time.timeZone = "Europe/Prague";

  users.mutableUsers = false;
  users.users.monk.passwordFile = "/mnt/persist/secrets/login/monk";
  users.users.root.passwordFile = "/mnt/persist/secrets/login/root";

  system.noGraphics = true;
  home-manager.users.monk.system.noGraphics = true;

  nix.buildMachines = [ {
    hostName = "localhost";
    system = "x86_64-linux";
    supportedFeatures = ["kvm" "nixos-test" "big-parallel" "benchmark"];
    maxJobs = 1;
  } ];
  nix.buildCores = 2;  # we're not in a hurry, and this way we don't swap much
  boot.tmpOnTmpfs = false;  # large builds are, well, large =(
  nix.gc.automatic = true;
  #nix.autoOptimiseStore = true;
  systemd.services.nix-daemon.serviceConfig = {
    CPUAffinity = "0-3";
    MemoryHigh = "12G"; MemoryMax = "13G"; MemorySwapMax = "13G";
  };

  home-manager.users.monk.language-support = [ "nix" "bash" ];

  home-manager.users.monk.services.syncthing.enable = true;

  system.stateVersion = "22.05";
  home-manager.users.monk.home.stateVersion = "22.05";

  environment.persistence."/mnt/persist" = {
    hideMounts = true;
    directories = [
      "/srv/nix-on-droid"
      "/var/lib/acme"
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
        ".config/syncthing"
        ".local/share/pygments-cache"
        ".local/share/xonsh"
        ".sync"
      ];
      files = [
        ".bash_history"
      ];
    };
  };
}
