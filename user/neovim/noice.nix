{ ... }:

{
  programs.nixvim = {
    # display statusline if there are at least two windows
    options.laststatus = 1;

    plugins.noice = {
      enable = true;
      cmdline.view = "cmdline";
      cmdline.format = {
        cmdline = { icon = false; conceal = false; };
        search_down = { icon = false; conceal = false; };
        search_up = { icon = false; conceal = false; };
        filter = { icon = false; conceal = false; };
        lua = { icon = false; conceal = false; };
        help = { icon = false; conceal = false; };
      };
      lsp = {
        signature.enabled = true;
        progress.enabled = false;
        signature.view = "virtualtext";
        hover.view = "virtualtext";
        documentation.view = "virtualtext";
      };
      views.mini = { position.row = "100%"; zindex = 50; };
      # replace confirmation shouldn't obscure the text it's asking about
      routes = [{
        view = "cmdline";
        filter.any = [ { event = "msg_show"; kind = "confirm_sub"; } ];
      }];
    };

    # TODO: weird that it has to be done fixed up this way
    autoCmd = [
      {
        event = [ "VimEnter" "Colorscheme" ];
        command = ":hi NoiceCursor gui=inverse";
      }
    ];

    # z-index helps cmdline overlay the last line; hide the rest anyway
    keymaps = [
      {
        key = ":";
        mode = "n";
        action = "<cmd>Noice dismiss<CR>:";
      }
    ];
  };
}
