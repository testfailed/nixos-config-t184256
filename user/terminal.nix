{ config, pkgs, inputs, ... }:

let
  alacritty-autoresizing =
    inputs.alacritty-autoresizing.defaultPackage.${pkgs.system};

  baseSettings = {
    env = { TERM = "xterm-256color"; };
    window.padding = { x = 0; y = 0; };
    dynamic_padding = true;  # I don't think it works
    font = {
      normal.family = "Iosevka Term";
      bold = { family = "Iosevka Term Medium"; style = "Normal"; };
      size = 24;
      # small y offsetting as iosevka-t184256 has custom -25% line spacing
      offset = { x = -2; y = -2; };
      glyph_offset = { x = -1; y = -1; };
    };
    colors.primary = { background = "#000000"; foreground = "#ffffff"; };
    bell = { animation = "EaseOutExpo"; duration = 100; color = "#7f7f7f"; };
    mouse.hide_when_typing = true;
    selection.save_to_clipboard = true;
    live_config_reload = false;
  };

in

{
  programs.alacritty = {
    enable = true;
    settings = baseSettings;
  };

  xdg.configFile."alacritty/autoresizing.cfg.py".source =
    "${inputs.alacritty-autoresizing}/autoresizing.cfg.py";

  home.wraplings = rec {
    term = "${alacritty-autoresizing}/bin/alacritty-autoresizing";
    term-hopper = "${term} --class TermHopper -e ~/.tmux-hopper.sh";
  };
}
