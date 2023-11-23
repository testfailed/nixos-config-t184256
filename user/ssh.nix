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
      bayroot = { user = "monk"; hostname = "192.168.99.3"; };
      araceae = { user = "monk"; hostname = "192.168.99.4"; };
      cashew = { user = "monk"; hostname = "duckweed.unboiled.info";
                 port = 221; };
      quince = { user = "monk"; hostname = "duckweed.unboiled.info";
                port = 226; };
      cocoa = { user = "monk"; hostname = "duckweed.unboiled.info";
                port = 227; };

      bayroot64 = {
        user = "monk";
        hostname = "2001:bc8:1d80:2232::1";
        proxyJump = "loquat";
      };
      araceae64 = {
        user = "monk";
        hostname = "2001:bc8:634:213e::1";
        proxyJump = "loquat";
      };
    };
  };
}
