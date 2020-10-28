self: super:

let
  xontribs = builtins.mapAttrs (_: f: (f { pkgs = super; }))
                               ((import ../../.autoimport).asAttrs ./xontribs);

  # fixes https://github.com/xonsh/xonsh/issues/3810
  ptk-3810 = super.python3Packages.prompt_toolkit.overridePythonAttrs (o: {
    src = super.fetchFromGitHub {
      owner = "t184256";
      repo = "python-prompt-toolkit";
      rev = "t184256";
      sha256 = "1xs48g50ans9bw1hm1cgw3v6j3zdx90gv2i3a1cvbl22afd63dvl";
    };
  });

  xonshLib = super.python3Packages.buildPythonPackage rec {
    inherit (super.xonsh) postPatch installCheckPhase
                          meta shellPath;
    propagatedBuildInputs = with super.python3Packages; [
      ply pygments
      ptk-3810
    ];
    pname = "xonsh";
    version = "0.9.24";
    src = super.fetchFromGitHub {
      owner = "xonsh";
      repo = "xonsh";
      rev = version;
      sha256 = "1nk7kbiv7jzmr6narsnr0nyzkhlc7xw3b2bksyq2j6nda67b9b3y";
    };
    prePatch = ''
      substituteInPlace xonsh/completers/bash_completion.py --replace \
        '{source}' \
        'PS1=x [ -r /etc/bashrc ] && source /etc/bashrc; {source}'
      '';
    checkInputs = with super; [
      python3Packages.pytest
      python3Packages.pytest-rerunfailures
      glibcLocales
      git
    ];
    postInstall = ''
      site_packages=$(python -c "import site; print(site.__file__.rsplit('/', 2)[-2])")
      xonsh=$out/lib/$site_packages/site-packages/xonsh/
      install -D -m644 xonsh/parser_table.py xonsh/__amalgam__.py $xonsh
      install -D -m644 xonsh/completers/__amalgam__.py $xonsh/completers/
      install -D -m644 xonsh/history/__amalgam__.py $xonsh/history/
      install -D -m644 xonsh/prompt/__amalgam__.py $xonsh/prompt/
      python -m compileall --invalidation-mode unchecked-hash $xonsh
      python -O -m compileall --invalidation-mode unchecked-hash $xonsh
    '';
  };

  makeXonshEnv = { extras }: super.python3.buildEnv.override {
      extraLibs = [ xonshLib ] ++ extras;
  };

  makeXonshWrapper = args: super.writeShellScriptBin "xonsh" ''
    exec ${makeXonshEnv args}/bin/python3 -Ou -m xonsh "$@"
  '';

  makeCustomizableXonsh = args:
    let
      this = (makeXonshWrapper args) // args;
    in
    this // rec {
      customize = a: makeCustomizableXonsh (args // a);
      withExtras = e: customize { extras = this.extras ++ e; };
      withXontribs = f: withExtras (f xontribs);
      withPythonPackages = f: withExtras (f super.python3Packages);
    };

  xonsh = makeCustomizableXonsh { extras = []; };
in
{
  inherit xonsh xontribs;
}
