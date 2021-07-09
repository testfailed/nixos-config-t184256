{ pkgs, ... }:

{
  # a basic set I'd like to have as root for recovery
  environment.systemPackages = with pkgs; [
    git
    htop iotop ncdu
    strace ltrace
    wget curl
    vis  # as an emergency text editor
  ];
}
