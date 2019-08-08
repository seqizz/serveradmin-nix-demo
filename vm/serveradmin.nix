{ config , pkgs , ... }:

let
  nixpkgs = import <nixpkgs> {};
  serveradmin-sock = "/run/uwsgi/serveradmin.sock";
  initialize_serveradmin = pkgs.writeShellScriptBin "initialize_serveradmin" ''
  serveradmin migrate
  serveradmin shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('test', 'test@example.com', 'test')"
  serveradmin collectstatic
  '';
in
{
  nixpkgs.config.packageOverrides = pkgs: rec {
    serveradmin = pkgs.callPackage ../packages/serveradmin.nix {
      allowedHosts = "['*']";
      secretKey = "WOW_SO_MUCH_SECRET";
      objectsPerPage = 100;
    };
    # Create a global python path
    pythonServeradmin = ( pkgs.python3.withPackages ( ps: with ps; (serveradmin).drvAttrs.pythonPath ++ [serveradmin]));
  };

  environment.systemPackages = with pkgs; [
    pythonServeradmin
    initialize_serveradmin
  ];

  users.extraUsers.serveradmin = {};

  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all ::1/128 trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE serveradmin WITH LOGIN SUPERUSER;
      CREATE ROLE root WITH LOGIN SUPERUSER;
      CREATE DATABASE serveradmin;
      GRANT ALL PRIVILEGES ON DATABASE serveradmin TO serveradmin;
      GRANT ALL PRIVILEGES ON DATABASE serveradmin TO root;
    '';
  };

  services.nginx = {
    enable = true;
    user = "serveradmin";
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    appendHttpConfig = ''
      server {
        listen 80 default_server;
        location /static/ {
            autoindex on;
            alias /www/serveradmin/_static/;
        }

        location / {
          uwsgi_pass unix://${serveradmin-sock};
        }
      }
    '';
  };

  services.uwsgi = {
    enable = true;

    # be nginx so we can read the socket from nginx easily
    user = "serveradmin";
    group = "nginx";

    plugins = ["python3"];
    instance = {
      type = "normal";
      master = true;
      processes = 24;
      threads = 2;
      chdir = "${pkgs.pythonServeradmin}/lib/python3.7/site-packages/serveradmin";
      wsgi-file = "${pkgs.pythonServeradmin}/lib/python3.7/site-packages/serveradmin/wsgi.py";
      socket = serveradmin-sock;
      logto = "/var/log/serveradmin.log";
      env = [
        # Need to set pythonhome for uwsgi, since otherwise it
        # makes up its own one.
        "PYTHONHOME=${pkgs.pythonServeradmin}"
      ];
    };
  };
}
