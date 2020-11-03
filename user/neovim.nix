{ config, pkgs, lib, ... }:

let
  withLang = lang: builtins.elem lang config.language-support;

  python-language-server-lighter = pkgs.python3Packages.python-language-server.override {
      providers = [ "rope" "pyflakes" "mccabe" "pycodestype" "pydocstyle"
                    "yapf" ];
  };
  cocConfig = {
    "codeLens.enable" = true;
    "diagnostic.enableMessage" = "jump";  # always, jump, never
    "diagnostic.level" = "hint";
    "diagnostic.virtualText" = true;
    "diagnostic.virtualTextCurrentLineOnly" = false;
    "coc.preferences.hoverTarget" = "echo";
    #suggest.acceptSuggestionOnCommitCharacter = true;
    suggest.autoTrigger = "none";
    languageserver.python = {
      command = "nvim-python3"; args = [ "-m" "pyls" ];
      filetypes = [ "python" ];
      settings.pyls = {
        enable = true;
        plugins = {
          jedi_completion.enabled = false;
          jedi_hover.enabled = false;
          jedi_references.enabled = false;
          jedi_signature_help.enabled = false;
          jedi_symbols = { enabled = false; all_scopes = true; };
          rope_completion.enabled = true;
          mccabe = { enabled = true; threshold = 15; };
          preload.enabled = true;
          pycodestyle.enabled = true;
          pydocstyle = {
            enabled = false;
            match = "(?!test_).*\\.py";
            matchDir = "[^\\.].*";
          };
          pyflakes.enabled = true;
          yapf.enabled = true;
        };
      };
    };
  };
  tabNineConfig = {
    disable_auto_update = true;
    enable_telemetry = false;
  };
in
{
  xdg.configFile."nvim/coc-settings.json".source =
    builtins.toFile "coc-settings.json" (builtins.toJSON cocConfig);
  xdg.configFile."TabNine/tabnine_config.json".source =
    builtins.toFile "tabnine_config.json" (builtins.toJSON tabNineConfig);
  programs.neovim = {
    enable = true;

    withPython = false;  # it's 2020!
    withRuby = false;
    withNodeJs = true;  # coc

    extraPackages = with pkgs; [
    ] ++ lib.optionals (withLang "bash") [
      nodePackages.bash-language-server
    ] ++ lib.optionals (withLang "python") (with python3Packages; [
    ]);
    extraPython3Packages = (ps: with ps; [
    ] ++ lib.optionals (withLang "python") [
    ]);

    plugins = with pkgs.vimPlugins; [
      # coc world
      {
        plugin = coc-nvim;  # kitchen sink
        config = ''
          inoremap <silent><expr> <TAB>
            \ pumvisible() ? coc#_select_confirm() :
            \ coc#expandableOrJumpable() ?
            \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump','''])\<CR>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
          function! s:check_back_space() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
          endfunction
          let g:coc_snippet_next = '<tab>'
          nmap <silent> { <Plug>(coc-diagostic-prev)
          nmap <silent> } <Plug>(coc-diagostic-next)
        '';
      }
      #coc-diagnostic  # non-LSP linting, not in 20.09
      coc-highlight  # nice coloring for colors
      coc-json
      coc-snippets
      coc-tabnine  # universal autocompleter
      coc-yaml

      # vim world
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
          hi CocFloating guibg=#222222
          hi CocErrorVirtualText guifg=#800000
          hi CocErrorFloat guifg=#800000
          hi CocWarningVirtualText guifg=#703000
          hi CocWarningFloat guifg=#ff6000
          hi CocInfoVirtualText guifg=#003070
          hi CocInfoFloat guifg=#3030ff
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
