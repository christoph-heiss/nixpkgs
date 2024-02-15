{ callPackage, fetchurl, lib, ... }@args:

{ version, hash }:

callPackage ../../../servers/http/nginx/generic.nix args {
  pname = "freenginx";
  inherit version;

  src = fetchurl {
    url = "https://nginx.org/download/nginx-${version}.tar.gz";
    inherit hash;
  };

  meta = with lib; {
    description = "A developer-supported fork of nginx, a reverse proxy and lightweight webserver";
    homepage    = "http://freenginx.org";
    license     = [ licenses.bsd2 ];
    platforms   = platforms.all;
    maintainers = with maintainers; [ christoph-heiss ];
  };
}
