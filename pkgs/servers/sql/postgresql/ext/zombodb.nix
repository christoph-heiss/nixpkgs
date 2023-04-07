{ lib
, fetchFromGitHub
, buildPgxExtension
, postgresql
}:

let
 pgMajorVersion = lib.versions.major postgresql.version;
in
buildPgxExtension rec {
  inherit postgresql;

  pname = "zombodb";
  version = "v3000.1.12";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-gBHhLkhgCPWRyD6cI9dtDreq7wbr9zh/s+zRUas482o=";
  };

  cargoSha256 = "sha256-iKV2WhjP7V3+OknVcat75CkbM/3wE7l8EgiwQfWvytI=";
  buildNoDefaultFeatures = true;
  buildFeatures = [ "pg${pgMajorVersion}" ];

  meta = with lib; {
    description = "Brings powerful text-search and analytics features to Postgres";
    longDescription = ''
      Uses Elasticsearch as an index type. Its comprehensive query language and
      SQL functions enable new and creative ways to query your relational data.
    '';
    homepage = "https://github.com/zombodb/zombodb";
    changelog = "https://github.com/zombodb/zombodb/releases/tag/${version}";
    maintainers = with maintainers; [ christoph-heiss ];
    platforms = postgresql.meta.platforms;
    license = licenses.asl20;
    broken = versionOlder postgresql.version "11";
  };
}
