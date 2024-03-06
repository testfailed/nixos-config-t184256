{ pkgs, ... }:

{
  programs.nixvim = {
    options = {
      termguicolors = true;
      wildoptions = "pum";
      pumblend = 20;
      winblend = 20;
    };
    colorscheme = "boring";
    extraPlugins = with pkgs.vimPlugins; [
      vim-boring  # my non-clownish color theme
      lush-nvim
      #shipwright
    ];
    plugins.rainbow-delimiters = {
      enable = true;
      highlight = [
        "RainbowDelimiterCyan"  # is, actually, grey
        "RainbowDelimiterBlue"
        "RainbowDelimiterYellow"
        "RainbowDelimiterGreen"  # not very noticeable
        "RainbowDelimiterOrange"
        "RainbowDelimiterViolet"
        "RainbowDelimiterRed"
      ];
    };
  };
}
