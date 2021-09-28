let pkgs = import <nixpkgs> { };
in pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3.pkgs.tensorflow
    pkgs.python3.pkgs.scipy
    pkgs.python3.pkgs.youtube-dl
    pkgs.python3.pkgs.pydub
    pkgs.python3.pkgs.librosa
    pkgs.python3.pkgs.numpy
    pkgs.python3.pkgs.matplotlib
    pkgs.python3.pkgs.scikit-learn
  ];
  shellHook = ''
    # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}
