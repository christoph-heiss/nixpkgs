{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "picoshare";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "mtlynch";
    repo = pname;
    rev = version;
    hash = "sha256-wx0LbHLqkEi7TWwD9ag1LW6ZlPU4ncAitOZl+Z7B36I=";
  };

  vendorHash = "sha256-qbnC6/PD+LwNlJRNRSY4GySuCJWiIV6YD6bKcIinyrs=";

  strictDeps = true;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A minimalist, easy-to-host service for sharing images and other files";
    homepage = "https://github.com/mtlynch/picoshare";
    changelog = "https://github.com/mtlynch/picoshare/releases/tag/${version}";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ christoph-heiss ];
    platforms = platforms.linux;
  };
}
