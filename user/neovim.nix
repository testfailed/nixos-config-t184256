{ config, pkgs, lib, ... }:

let
  withLang = lang: builtins.elem lang config.language-support;
in
{
  programs.neovim = {
    enable = true;

    withPython = false;  # it's 2020!
    withRuby = false;
    #withNodeJs = true;

    extraPackages = with pkgs; [
    ] ++ lib.optionals (withLang "bash") [
      shellcheck
    ] ++ lib.optionals (withLang "python") [
      (python3Packages.python-language-server.override {
        providers = [ "autopep" "mccabe" "pycodestype" "pydocstyle"
                      "pyflakes" "yapf"];
      })
      python3Packages.isort
      python3Packages.yapf
    ];
    extraPython3Packages = (ps: with ps; [
    ] ++ lib.optionals (withLang "python") [
    ]);

    plugins = with pkgs.vimPlugins; [
      vim-eunuch  # helpers for UNIX: :SudoWrite, :Rename, ...
      vim-lastplace  # remember position
      vim-nix  # syntax files and indentation
      vim-repeat  # better repetition
      vim-sleuth  # guess indentation
      tcomment_vim  # <gc> comment action
      vim-undofile-warn   # undofile enabled + warning on overundoing
      {
        plugin = vim-better-whitespace;  # trailing whitespace highlighting
        config = ''
          let g:show_spaces_that_precede_tabs = 1
	'';
      }
      {
        plugin = vim-easymotion;  # faster motion bound to <s>
        config = ''
          nmap s <Plug>(easymotion-overwin-f)
          let g:EasyMotion_smartcase = 1
          let g:EasyMotion_keys="tnaowyfu'x.c,rise"  " combos start with last
	'';
      }
      {
        plugin = vim-gitgutter;  # color changed lines
        config = ''
          " but don't show signs column and don't do that until I press <gl>
          autocmd BufWritePost * GitGutter
          let g:gitgutter_highlight_lines = 0
          :set signcolumn=no
          autocmd VimEnter,Colorscheme * :hi GitGutterAddLine guibg=#002200
          autocmd VimEnter,Colorscheme * :hi GitGutterChangeLine guibg=#222200
          autocmd VimEnter,Colorscheme * :hi GitGutterDeleteLine guibg=#220000
          autocmd VimEnter,Colorscheme * :hi GitGutterChangeDeleteLine guibg=#220022
          nnoremap <silent> gl :GitGutterLineHighlightsToggle<CR>:IndentGuidesToggle<CR>
	'';
      }
      {
        plugin = vim-indent-guides;  # indent guides
        config = ''
          let g:indent_guides_enable_on_vim_startup = 1
          let g:indent_guides_auto_colors = 0
          autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#000000
          autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#121212
        '';
      }
      {
	plugin = vim-monotone;  # non-clownish color theme
        config = ''
          let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
          let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
          set termguicolors
          let g:monotone_color = [0, 0, 100]
          let g:monotone_contrast_factor = 1
          "let g:monotone_secondary_hue_offset = 200
          let g:monotone_emphasize_whitespace = 1
          colorscheme monotone
          hi MatchParen gui=reverse
          hi EndOfBuffer guifg=#303030
          hi Search guifg=#000000 guibg=#bbbbdd
          hi normal guibg=black
          set colorcolumn=80
          hi ColorColumn guifg=#ddbbbb guibg=#0a0a0a
          hi diffAdded guifg=#e0ffe0
          hi diffRemoved guifg=#ffe0e0
          hi diffLine guifg=#bbbbbb
          hi gitHunk guifg=#dddddd
          set wildoptions=pum
          set pumblend=20
          set winblend=20
          hi Pmenu guifg=#ffffff
        '';
       }
      {
        plugin = vimagit;  # my preferred git interface for committing
        config = ''
          let g:magit_auto_close = 1
        '';
      }
    ];

    extraConfig = ''
      set shell=/bin/sh
      set laststatus=1  " display statusline if there are at least two windows
      set suffixes+=.pdf  " don't offer to open pdfs
      set scrolloff=5
      nnoremap <C-L> :nohlsearch<CR><C-L>  " clear search highlighting
      set diffopt+=algorithm:patience
    '';

    viAlias = true;
  };

  home.wraplings = {
    view = "nvim -R";
    vimagit = "nvim +MagitOnly";
  };
  home.sessionVariables.EDITOR = "nvim";
}
