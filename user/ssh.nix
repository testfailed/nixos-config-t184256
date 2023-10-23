{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      fig = { user = "monk"; hostname = "fig.unboiled.info"; };
      mango = { user = "monk"; hostname = "mango.unboiled.info"; };
      duckweed = { user = "monk"; hostname = "duckweed.unboiled.info"; };
      loquat = { user = "monk"; hostname = "loquat.unboiled.info"; };
      jungle = { user = "root"; hostname = "jungle.lan"; };
      bayroot = { user = "monk"; hostname = "bayroot.unboiled.info"; };
      araceae = { user = "monk"; hostname = "araceae.unboiled.info"; };
      cashew = { user = "monk"; hostname = "duckweed.unboiled.info";
                 port = 221; };
      cocoa = { user = "monk"; hostname = "duckweed.unboiled.info";
                port = 227; };
    };
  };
}
