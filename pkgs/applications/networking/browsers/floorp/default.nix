{ stdenv
, lib
, fetchFromGitHub
, buildMozillaMach
, nixosTests
}:

let
  locales = [
    "ar" "cs" "da" "de" "el" "en-US" "en-GB" "es-ES" "fr" "hu" "id" "it" "ja"
    "ko" "lt" "nl" "nn-NO" "pl" "pt-BR" "pt-PT" "ru" "sv-SE" "th" "tr" "uk"
    "vi" "zh-CN" "zh-TW"
  ];
in
((buildMozillaMach rec {
  pname = "floorp";
  packageVersion = "11.11.2";
  applicationName = "Floorp";
  binaryName = "floorp";
  branding = "browser/branding/official";
  requireSigning = false;
  allowAddonSideload = true;

  # Must match the contents of `browser/config/version.txt` in the source tree
  version = "115.10.0";

  src = fetchFromGitHub {
    owner = "Floorp-Projects";
    repo = "Floorp";
    fetchSubmodules = true;
    rev = "v${packageVersion}";
    hash = "sha256-a9f4+t2w8aOOLNaKkr+FuY0ENa/Nkukg9pvJTiUMfWk=";
  };

  extraConfigureFlags = [
    "--with-app-name=${pname}"
    "--with-app-basename=${applicationName}"
    "--with-unsigned-addon-scopes=app,system"
    "--with-l10n-base=../floorp/browser/locales"
  ];

  extraPostBuild = ''
    set -x
    cp floorp/browser/locales/jar.mn browser/locales/jar.mn
    ./mach package-multi-locale --locales ${builtins.concatStringsSep " " locales}
    find . -type f -name '*.jar'
    exit 1
  '';

  meta = {
    description = "A fork of Firefox, focused on keeping the Open, Private and Sustainable Web alive, built in Japan";
    homepage = "https://floorp.app/";
    maintainers = with lib.maintainers; [ christoph-heiss ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
                                           # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    license = lib.licenses.mpl20;
    mainProgram = "floorp";
  };
  tests = [ nixosTests.floorp ];
}).override {
  # Upstream build configuration can be found at
  # .github/workflows/src/linux/shared/mozconfig_linux_base
  privacySupport = true;
  webrtcSupport = true;
  enableOfficialBranding = false;
  googleAPISupport = true;
  mlsAPISupport = true;
}).overrideAttrs (prev: {
  MOZ_DATA_REPORTING = "";
  MOZ_TELEMETRY_REPORTING = "";
})
