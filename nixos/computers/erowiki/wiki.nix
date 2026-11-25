{
  config,
  lib,
  pkgs,
  ...
}:
let
  wikiHost = "foxtato-softworks.${config.erowiki.domain}";
  secretsDir = "/var/lib/mediawiki-secrets";
in
{
  config = {
    services.mediawiki = {
      enable = true;
      name = "Historica of Lovely Fate";
      webserver = "nginx";
      nginx.hostName = wikiHost;
      url = "https://${wikiHost}";

      # Only read by install.php on an empty database. After the production
      # dump is imported the existing admin accounts are what count, but the
      # module requires the option and the file has to exist on first boot.
      passwordFile = "${secretsDir}/admin-password";

      # With createLocally the module insists the database and user are both
      # "mediawiki" (socket auth, no password). The Docker database was named
      # my_wiki; a single-database mysqldump has no USE statement, so it
      # restores into "mediawiki" unchanged.
      database = {
        type = "mysql";
        createLocally = true;
      };

      # null = bundled with the MediaWiki tarball, just enable it.
      extensions = {
        CategoryTree = null;
        ConfirmEdit = null;
        ImageMap = null;
        MultimediaViewer = null;
        Nuke = null;
        PageImages = null;
        ParserFunctions = null;
        Poem = null;
        ReplaceText = null;
        Scribunto = null;
        TemplateData = null;
        TextExtracts = null;
        VisualEditor = null;
        WikiEditor = null;

        PortableInfobox = pkgs.fetchFromGitHub {
          owner = "Universal-Omega";
          repo = "PortableInfobox";
          rev = "a63e0a542c3f40b62af65eb16e34bd2b056d92bf"; # main
          hash = "sha256-wIR+lLKOpVvmhI/X3r3HdWey4OkgpsKjlQdx728lLR8=";
        };
        DarkMode = pkgs.fetchFromGitHub {
          owner = "wikimedia";
          repo = "mediawiki-extensions-DarkMode";
          rev = "6e20a5cdc2908de50f7ad9944ad63e78d16b09a4"; # REL1_46
          hash = "sha256-X3PC30kZRUSDzoSP60mWXAclw8NfQxi6uJab+qTEFfQ=";
        };
      };
      skins = {
        Cosmos = pkgs.fetchFromGitHub {
          owner = "wikimedia";
          repo = "mediawiki-skins-Cosmos";
          rev = "59743de6845e732cd8267f1a714863dcd9718032"; # REL1_46
          hash = "sha256-5LInoF4DChGxCj236BRD7C34McvXZuV1c4EYRPEM6wA=";
        };
      };

      # Sized for 1GB. The Docker setup capped Apache at 10 workers; php-fpm
      # workers are lighter but each can still reach memory_limit.
      poolConfig = {
        "pm" = "dynamic";
        "pm.max_children" = 6;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 1;
        "pm.max_spare_servers" = 3;
        "pm.max_requests" = 500;
      };

      extraConfig = ''
        $wgScribuntoEngineConf['luastandalone']['luaPath'] = "${pkgs.lua5_1}/bin/lua";
        require_once "${./wiki-settings.php}";

        # Keys that must not land in the world-readable nix store: Turnstile,
        # $wgUpgradeKey, and the production $wgSecretKey (set here, it
        # overrides the module's generated secret.key). See the README.
        if ( is_readable( "${secretsDir}/secrets.php" ) ) {
          require_once "${secretsDir}/secrets.php";
        }
      '';
    };

    services.phpfpm.pools.mediawiki.phpOptions = {
      upload_max_filesize = "20M";
      post_max_size = "21M";
      memory_limit = "256M";
      max_execution_time = 300;
    };

    # The secrets are copied in by hand as root (nixos-anywhere --extra-files
    # on a fresh install, before the mediawiki user exists); these fix up
    # ownership on every boot. Root-owned with group read, and deliberately
    # not under /var/lib/mediawiki: tmpfiles refuses to touch a root-owned
    # file inside a directory another user owns, and the wiki only needs to
    # read these, not change them. The group is nginx because that is the
    # mediawiki user's group in the module (nginx can reach the wiki through
    # the php-fpm socket anyway, so a separate group would add nothing).
    systemd.tmpfiles.rules = [
      "d ${secretsDir} 0750 root nginx - -"
      "z ${secretsDir}/admin-password 0640 root nginx - -"
      "z ${secretsDir}/secrets.php 0640 root nginx - -"
    ];

    services.mysql = {
      # Newest MariaDB LTS in nixpkgs. Production runs 13.0 from the Docker
      # image, and a newer data directory cannot be opened by an older server,
      # so the move is a mysqldump + restore, never a copy of /var/lib/mysql.
      package = pkgs.mariadb_118;
      settings.mysqld = {
        innodb_buffer_pool_size = "128M";
        key_buffer_size = "8M";
        aria_pagecache_buffer_size = "16M";
        max_connections = 30;
        table_open_cache = 400;
        performance_schema = "OFF";
      };
    };

    # Nightly dump to /var/backup/mysql/mediawiki.gz (overwritten each night).
    services.mysqlBackup = {
      enable = true;
      databases = [ "mediawiki" ];
      calendar = "03:15:00";
    };
  };
}
