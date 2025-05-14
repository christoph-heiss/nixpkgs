{
  lib,
  fetchFromGitHub,
  buildGoModule,
  oath-toolkit,
  openldap,
  versionCheckHook,
  tree,
}:

buildGoModule rec {
  pname = "glauth";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "glauth";
    repo = "glauth";
    rev = "v${version}";
    hash = "sha256-UUTL+ZnHRSYuD/TUYpsuo+Nu90kpA8ZL4XaGz6in3ME=";
  };

  vendorHash = "sha256-VnhKdOKWrXadC+nhUqkhNX8L61IYYD9TVPEsZwSP2YM=";

  postPatch = ''
    mkdir -p v2/pkg/embed
    echo 'package embed' > v2/pkg/embed/sqlite.go
    echo 'github.com/davecgh/go-spew v1.1.0/go.mod h1:J7Y8YcW2NihsgmVo/mv3lAwl/skON4iLHjSsI+c5H38=' >> v2/go.sum

    substituteInPlace v2/internal/version/const.go \
      --replace-fail 'Version = "v2.3.1"' 'Version = "v${version}"'
  '';

  nativeCheckInputs = [
    oath-toolkit
    openldap
  ];

  strictDeps = true;

  modRoot = "v2";

  tags = "noembed";

  # Disable go workspaces to fix build.
  env.GOWORK = "off";

  # Based on ldflags in v2/Makefile
  ldflags = [
    "-s"
    "-w"
    "-X"
    "github.com/glauth/glauth/v2/internal/version.Version=${version}"
  ];

  # Tests fail in the sandbox.
  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = with lib; {
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    changelog = "https://github.com/curl/trurl/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [
      bjornfor
      christoph-heiss
    ];
    mainProgram = "glauth";
  };
}
