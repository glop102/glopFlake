{
  config,
  lib,
  ...
}:
let
  cfg = config.erowiki;
in
{
  options.erowiki = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "erowiki.net";
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # On a droplet that does not (yet) own the DNS names, validation simply
    # fails and nginx keeps serving the self-signed placeholder certs the acme
    # module generates. That droplet registers its own ACME account, so the
    # failures do not count against the production account's limits.
    security.acme = {
      acceptTerms = true;
      defaults.email = "webmaster@glop.tech";
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      # Leave ssl_early_data off (the nginx default). CVE-2026-132779 is a
      # CPU loop in the early-data path, fixed only in 1.30.8 / 1.31.10.

      virtualHosts = {
        # Landing page. Also the default server, so unknown Host headers and
        # bare-IP requests land here, as they did under SWAG.
        ${cfg.domain} = {
          default = true;
          serverAliases = [ "www.${cfg.domain}" ];
          forceSSL = true;
          enableACME = true;
          root = ./www;
        };

        # Old name for the wiki. Redirect everything, path included.
        "magicalcamp.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          globalRedirect = "foxtato-softworks.${cfg.domain}";
        };

        # The wiki vhost itself is created by services.mediawiki (wiki.nix);
        # TLS and the legacy-URL redirects are layered on here.
        "foxtato-softworks.${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            client_max_body_size 21M;
          '';
          locations = {
            # Under Docker the wiki lived at the web root ($wgScriptPath = ""),
            # so links out in the world look like /index.php/Page and
            # /images/a/ab/File.png. The NixOS module serves scripts from /w/
            # and articles from /wiki/, so send the old shapes there.
            # [^\r\n] rather than .: PCRE's . matches \r, and a decoded %0D in
            # the path would otherwise be copied into the Location header.
            "~ ^/index\\.php/([^\\r\\n]*)$".return = "301 /wiki/$1$is_args$args";
            "~ ^/(index|api|load|rest|thumb|opensearch_desc|img_auth)\\.php$".return =
              "301 /w/$1.php$is_args$args";
            "^~ /images/".extraConfig = ''
              rewrite ^/images/(.*)$ /w/images/$1 permanent;
            '';
          };
        };
      };
    };
  };
}
