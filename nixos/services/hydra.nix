{ pkgs, inputs, ... }:

let
  hydraPkg = inputs.hydra.defaultPackage.${pkgs.system};
  privKey = "/var/secrets/nix-cache/priv-key.pem";
in
{
  imports = [ ./postgresql.nix ];
  # hydra-create-user monk --full-name 'Alexander Sosedkin' \
  #  --email-address 'monk@unboiled.info' --role admin
  # nix-store --generate-binary-cache-key hydra-unboiled-info \
  #   /mnt/persist/var/secrets/nix-cache/priv-key.pem \
  #   /mnt/persist/var/secrets/nix-cache/pub-key.pem
  # chown -R hydra:hydra /mnt/persist/var/secrets/nix-cache
  # chmod 440 /mnt/persist/var/secrets/nix-cache/priv-key.pem
  # psql hydra
  #   ALTER TABLE BuildOutputs ALTER COLUMN path DROP NOT NULL;
  #   ALTER TABLE BuildStepOutputs ALTER COLUMN path DROP NOT NULL;
  #   ALTER TABLE BuildStepOutputs ADD contentAddressed BOOLEAN NOT NULL DEFAULT 'f';

  nix.settings.trusted-users = [ "hydra" "hydra-queue-runner" "hydra-www" ];
  nix.settings.keep-derivations = true;
  nix.settings.keep-outputs = true;
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.unboiled.info";
    notificationSender = "hydra@unboiled.info";
    useSubstitutes = true;
    listenHost = "127.0.0.1";
    port = 4000;
    package = hydraPkg;
    minimumDiskFree = 20;  # GB
    buildMachinesFiles = [ "/mnt/persist/secrets/hydra/machines" ];
  };
  services.harmonia = {
    enable = true;
    signKeyPath = privKey;
  };
  nix.settings.allowed-users = [ "harmonia" ];
  services.nginx = {
    recommendedProxySettings = true;
    virtualHosts."hydra.unboiled.info" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:4000";
      extraConfig =
        let
          to-harmonia-base = ''
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            brotli on;
            brotli_types application/x-nix-archive;
          '';
          to-harmonia = ''
            proxy_pass http://127.0.0.1:5000;
            ${to-harmonia-base}
          '';
        in
        # see https://fzakaria.github.io/nix-http-binary-cache-api-spec
        # and https://github.com/nix-community/harmonia/issues/120
        ''
          proxy_cache off;
          location ~ "^/nar/([a-z0-9]{32})-.*\.narinfo$" {
            proxy_pass http://127.0.0.1:5000/$1.narinfo$is_args$args;
            ${to-harmonia-base}
          }
          location ~ "^/([a-z0-9]{32}).narinfo$" { ${to-harmonia} }
          location ~ ^/nix-cache-info { ${to-harmonia} }
          location ~ ^/.+\.ls$ { ${to-harmonia} }
          location ~ ^/nar/.*\.nar$ { ${to-harmonia} }
          location ~ ^/nar/.*\.nar\. { ${to-harmonia} }
          location ~ ^/log/.+$ { ${to-harmonia} }
        '';
    };
  };

  systemd = {
    timers.flake-autoupdate = {
      wantedBy = [ "timers.target" ];
      partOf = [ "flake-autoupdate.service" ];
      timerConfig.OnCalendar = "0/2:08";  # once in 2 hours, offset by 8 min
    };
    services.flake-autoupdate = {
      serviceConfig.User = "hydra";
      serviceConfig.Type = "oneshot";
      script = ''
        set -uexo pipefail
        export PATH=${pkgs.git}/bin:${pkgs.nix}/bin:$PATH
        WD=/var/lib/flake-autoupdate; mkdir -p $WD
        NEW=$WD/.new-t184256-nix-configs
        FRZ=$WD/.frz-t184256-nix-configs
        OLD=$WD/.old-t184256-nix-configs
        LNK=$WD/t184256-nix-configs
        export GIT_AUTHOR_NAME="Auto Update"
        export GIT_AUTHOR_EMAIL="hydra@unboiled.info"
        export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
        export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
        [[ -e $WD/nixpkgs ]] || \
          ${pkgs.git}/bin/git clone https://github.com/NixOS/nixpkgs $WD/nixpkgs
        pushd $WD/nixpkgs
          ${pkgs.git}/bin/git pull --ff-only
          LAGGING=$(git rev-parse 'master@{2 hours ago}')
        popd
        [[ -e $NEW ]] && rm -rf $NEW
        [[ -e $OLD ]] && { cp -r $OLD $FRZ; ln -sfn $FRZ $LNK; }
        ${pkgs.git}/bin/git clone https://github.com/t184256/nix-configs $NEW \
                                  --reference-if-able $OLD --dissociate
        rm -rf $OLD
        pushd $NEW
          for branch in main staging; do
            git checkout $branch
            git checkout -b $branch-autoupdate
            time=$(date +%FT%T)
            nix flake update --show-trace \
                             --override-input nixpkgs \
                                              github:NixOS/nixpkgs?ref=$LAGGING
            if [[ -n "$(git status --porcelain)" ]]; then
              git add flake.lock
              git commit -m "AUTOUPDATE $branch $time"
            else
              echo "no updates found for $branch $time"
            fi
          done
        popd
        mv $NEW $OLD; ln -sfn $OLD $LNK; rm -rf $FRZ $NEW
      '';
    };
  };

  environment.persistence."/mnt/persist".directories = [
    {
      directory = "/var/secrets/nix-cache";
      user = "hydra"; group = "hydra";
    }
    {
      directory = "/var/lib/hydra";
      user = "hydra"; group = "hydra";
    }
    {
      directory = "/var/lib/flake-autoupdate";
      user = "hydra"; group = "hydra";
    }
  ];
}
