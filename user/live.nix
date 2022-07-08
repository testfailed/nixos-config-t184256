{ lib, config, pkgs, ... }:

let
  live-network = pkgs.writeShellScriptBin "live-network" ''
    set -uexo pipefail
    [[ -e /dev/disk/by-partlabel/VTOYEFI ]]
    if [[ -e /run/media/monk/VTOYEFI/secrets.7z.gpg ]]; then
      cp -rv /run/media/monk/VTOYEFI/secrets.7z.gpg /tmp/
    else
      mkdir /tmp/VTOYEFI
      sudo mount -o ro /dev/disk/by-partlabel/VTOYEFI /tmp/VTOYEFI
      cp -rv /tmp/VTOYEFI/secrets.7z.gpg /tmp/
      sudo umount /tmp/VTOYEFI
      rm -d /tmp/VTOYEFI
    fi

    ${pkgs.gnupg}/bin/gpg -d /tmp/secrets.7z.gpg > /tmp/secrets.7z
    mkdir /tmp/secrets
    pushd /tmp/secrets
      ${pkgs.p7zip}/bin/7z x /tmp/secrets.7z
    popd
    sudo cp -r /tmp/secrets/*.nmconnection \
               /etc/NetworkManager/system-connections/
    sudo chown -R root:root /etc/NetworkManager/system-connections
    sudo chmod -R 600 /etc/NetworkManager/system-connections
    sudo chmod 700 /etc/NetworkManager/system-connections
    sudo systemctl restart NetworkManager
    rm -r /tmp/secrets.7z
    rm -r /tmp/secrets
    touch /tmp/.network-configured
  '';
  inst = pkgs.writeShellScriptBin "inst" ''
    echo success; read
  '';
in
{
  imports = [ ./config/no-graphics.nix ./config/live.nix ];

  xdg.desktopEntries =
    lib.mkIf (! config.system.noGraphics && config.system.live) {
      live-network = {
        name = "Configure network";
        genericName = "Configure network";
        icon = "networkmanager";
        exec = "${live-network}";
        terminal = true;
      };
    };

  home.packages = lib.mkIf config.system.live [ live-network inst ];

  dconf.settings =
    lib.mkIf (! config.system.noGraphics && config.system.live) {
      "/org/gnome/desktop/screensaver" = {
        lock-enabled = false;
        idle-activation-enabled = false;
      };
    };
}