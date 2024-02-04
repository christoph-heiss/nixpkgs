{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "mar";
  version = "3.1.0";

  disabled = python3Packages.pythonOlder "3.3";

  src = fetchFromGitHub {
    owner = "mozilla-releng";
    repo = "build-mar";
    rev = "v${version}";
    hash = "sha256-Cfa5IEr6jq0iMc5Q0vTtOc+GJuoXMmJ5sC0MlglmTYY=";
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    asn1crypto
    click
    construct
    cryptography
  ];

  pythonRelaxDeps = [ "backports.lzma" "backports-lzma" ];

  preCheck = ''
    export PY_IGNORE_IMPORTMISMATCH=1
  '';

  checkInputs = with python3Packages; [
    pytestCheckHook
    tox
    hypothesis
    mock
  ];

  pythonImportsCheck = [ "mardor" ];

  meta = with lib; {
    description = "Utility for managing mar files";
    homepage = "https://github.com/mozilla-releng/build-mar";
    changelog = "https://github.com/mozilla-releng/build-mar/releases/tag/v${version}";
    license = licenses.mpl20;
    maintainers = with maintainers; [ christoph-heiss ];
  };
}
