import ./make-test-python.nix (
  { pkgs, ... }:
  let
    mkMachine =
      virtualHosts:
      {
        config,
        pkgs,
        ...
      }:
      {
        security.pki.certificates = [
          (builtins.readFile ./common/acme/server/ca.cert.pem)
        ];

        services.nginx = {
          enable = true;
          additionalModules = [ pkgs.nginxModules.security-headers ];
          inherit virtualHosts;
        };

        networking = {
          hosts."127.0.0.1" = builtins.attrNames config.services.nginx.virtualHosts;
          firewall.allowedTCPPorts = [ 443 ];
          firewall.allowedUDPPorts = [ 443 ];
        };
      };
  in
  {
    name = "nginx-security-headers";

    nodes = {
      machine = mkMachine {
        default = {
          default = true;
          locations = {
            "/".return = "200 'Hello World\n'";
            "/index.html".return = "200 '<html><head><title>Hello World</title></head></html>\n'";
            "/test.css".return = "200 'h1 {}\n'";
          };
          extraConfig = ''
            security_headers on;
            hide_server_tokens on;
          '';
        };
        "acme.test" = {
          onlySSL = true;
          sslCertificate = ./common/acme/server/acme.test.cert.pem;
          sslCertificateKey = ./common/acme/server/acme.test.key.pem;
          locations."/index.html".return = "200 '<html><head><title>Hello World</title></head></html>\n'";
          extraConfig = ''
            security_headers on;
            hide_server_tokens on;
          '';
        };
      };

      tls_no_hsts_preload = mkMachine {
        "acme.test" = {
          onlySSL = true;
          sslCertificate = ./common/acme/server/acme.test.cert.pem;
          sslCertificateKey = ./common/acme/server/acme.test.key.pem;
          locations."/index.html".return = "200 '<html><head><title>Hello World</title></head></html>\n'";
          extraConfig = ''
            security_headers on;
            security_headers_hsts_preload off;
          '';
        };
      };
    };
    testScript = ''
      machine.wait_for_unit("nginx.service")

      expected = "Hello World"
      response = machine.wait_until_succeeds("curl -s http://127.0.0.1/")
      assert expected in response, f"Expected {expected}, got {response}"

      # https://github.com/GetPageSpeed/ngx_security_headers?tab=readme-ov-file#hide_server_tokens
      missingHeaders = [
        'Server:',
        'X-Powered-By',
        'X-Page-Speed',
        'X-Varnish',
      ]

      def assert_headers(response: str, headers: list[str]):
        response = response.lower()
        for header in headers:
          header = header.lower()
          assert header in response, f"Expected header '{header}' to be present in '{response}'"
        for header in missingHeaders:
          header = header.lower()
          assert header not in response, f"Expected header '{header}' to be missing from response"

      # See
      # https://github.com/GetPageSpeed/ngx_security_headers?tab=readme-ov-file#security_headers
      # for all the options & when what header should be present

      assert_headers(
        machine.succeed("curl --verbose --head http://default"),
        [
          'X-Content-Type-Options: nosniff',
          'Referrer-Policy: strict-origin-when-cross-origin',
        ]
      )

      assert_headers(
        machine.succeed("curl --verbose --head http://default/index.html"),
        [
          'X-Content-Type-Options: nosniff',
          'X-XSS-Protection: 0',
          'Referrer-Policy: strict-origin-when-cross-origin',
          'X-Frame-Options: SAMEORIGIN',
        ]
      )

      assert_headers(
        machine.succeed("curl --verbose --head http://default/test.css"),
        [
          'X-Content-Type-Options: nosniff',
          'Referrer-Policy: strict-origin-when-cross-origin',
        ]
      )

      assert_headers(
        machine.succeed("curl --verbose --head https://acme.test/index.html"),
        [
          'Strict-Transport-Security: max-age=31536000; includeSubDomains; preload',
          'X-Content-Type-Options: nosniff',
          'X-XSS-Protection: 0',
          'Referrer-Policy: strict-origin-when-cross-origin',
        ]
      )

      assert_headers(
        tls_no_hsts_preload.succeed("curl --verbose --head https://acme.test/index.html"),
        [
          'Strict-Transport-Security: max-age=31536000; includeSubDomains',
          'X-Content-Type-Options: nosniff',
          'X-XSS-Protection: 0',
          'Referrer-Policy: strict-origin-when-cross-origin',
        ]
      )
    '';
  }
)
