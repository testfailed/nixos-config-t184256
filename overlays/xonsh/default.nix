self: super:

let
  xontribs = builtins.mapAttrs (_: f: (f { pkgs = super; }))
                               ((import ../../.autoimport).asAttrs ./xontribs);

  # avoids https://github.com/xonsh/xonsh/issues/3810
  ptk = super.python3Packages.prompt_toolkit.overridePythonAttrs (o: rec {
    version = "3.0.4";
    src = super.fetchFromGitHub {
      owner = "prompt-toolkit";
      repo = "python-prompt-toolkit";
      rev = version;
      sha256 = "040lcqha16rsddiymlrjx32p92rra27zal78gv8v9pqg1xky18vy";
    };
  });

  xonshLib = super.python3Packages.buildPythonPackage rec {
    inherit (super.xonsh) postPatch
                          meta shellPath;
    pname = "xonsh";
    version = "0.10.1";
    src = super.fetchFromGitHub {
      owner = "xonsh";
      repo = "xonsh";
      rev = version;
      sha256 = "03ahay2rl98a9k4pqkxksmj6mcg554jnbhw9jh8cyvjrygrpcpch";
    };
    propagatedBuildInputs = with super.python3Packages; [
      ply
      pygments
      ptk
    ];
    prePatch = ''
      substituteInPlace xonsh/completers/bash_completion.py --replace \
        '{source}' \
        'PS1=x [ -r /etc/bashrc ] && source /etc/bashrc; {source}'
    '';
    preCheck = ''
      HOME=$TMPDIR
    '';
    checkInputs = with super; [ glibcLocales git ] ++ (with python3Packages; [
      pytestCheckHook pytest-subprocess pytest-rerunfailures
    ]);
    disabledTests = [
      # fails on sandbox
      "test_colorize_file"
      "test_loading_correctly"
      "test_no_command_path_completion"
      # fails on non-interactive shells
      "test_capture_always"
      "test_casting"
      "test_command_pipeline_capture"
      "test_dirty_working_directory"
      "test_man_completion"
      "test_vc_get_branch"
    ];
    disabledTestPaths = [
      # fails on non-interactive shells
      "tests/prompt/test_gitstatus.py"
      "tests/completers/test_bash_completer.py"
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
      extraLibs = [ self.xonshLib ] ++ extras;
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
  inherit xonsh xontribs xonshLib;
}
