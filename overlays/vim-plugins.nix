self: super:

{
  vimPlugins = super.vimPlugins // {
    vim-monotone = super.pkgs.vimUtils.buildVimPluginFrom2Nix {
      pname = "vim-monotone";
      version = "2020719";
      src = super.fetchFromGitHub {
        owner = "Lokaltog";
        repo = "vim-monotone";
        rev = "5393343ff2d639519e4bcebdb54572dfe5c35686";
        sha256 = "0wyz5biw6vqgrlq1k2354mda6r36wga30rjaj06div05k3g7xhq4";
      };
    };
  };
}
