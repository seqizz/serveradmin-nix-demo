{ stdenv
, fetchFromGitHub
, python3Packages
, writeText
, secretKey
, allowedHosts ? "['127.0.0.1', '::1']"
, appendConfig ? ""
, timeZone ? ""
, sentryDsn ? ""
, objectsPerPage ? 25
, mediaRoot ? "/www/serveradmin/_media"
, staticRoot ? "/www/serveradmin/_static"
, debug ? false
}:

let
  configText = ''
  """Serveradmin configuration

  Shows some boilerplate comments also. Use "appendConfig" to append custom.
  """

  # # Make this unique, and don't share it with anybody.
  SECRET_KEY = "${secretKey}"

  # # Enable debugging to see what's going on during development.
  DEBUG = ${if debug then "True" else "False"}
  ALLOWED_HOSTS = ${allowedHosts}

  # # On Unix systems, a value of None will cause Django to use the same
  # # timezone as the operating system. If running in a Windows environment this
  # # must be set to the same as your system time zone.
  ${if (timeZone == "") then "# TIME_ZONE = 'Europe/Berlin'" else "TIME_ZONE = '${timeZone}'"}

  # # The default django logging config will send errors this way.
  # ADMINS = (
  #     ('Your Name', 'your_email@example.com'),
  # )
  # MANAGERS = ADMINS

  # # Log errors to sentry
  ${if (sentryDsn == "") then "# SENTRY_DSN = ''" else "SENTRY_DSN = '${sentryDsn}'"}

  # # See http://docs.djangoproject.com/en/dev/topics/logging for
  # # more details on how to customize your logging configuration.
  # LOG_LEVEL = 'DEBUG' if DEBUG else 'INFO'
  # LOGGING['loggers']['serveradmin'] = {'level': LOG_LEVEL}
  # LOGGING['loggers']['myapp'] = {'level': LOG_LEVEL}

  # # See https://docs.djangoproject.com/en/dev/ref/settings/#databases
  # # for more detauls on how to configure your database connection.
  # DATABASES = {
  # }

  # # Load additional middleware classes
  # MIDDLEWARE += []

  # # Load additional django apps
  # INSTALLED_APPS += []

  # # Load additional menu items
  # MENU_TEMPLATES += []

  # # How many objects are shown in servershell per page by default
  OBJECTS_PER_PAGE = ${toString objectsPerPage}

  # # Graphite URL is required to generate graphic URL's.  Normal graphs are
  # # requested from Graphite on the browser. Small graphs on the overview page are
  # # requested and stored by the Serveradmin from the Graphite. Graphs are stored
  # # by the job called "gensprites" under directory graphite/static/graph_sprite.
  # # They are also merged into single images for every server to reduce the
  # # requests to the Serveradmin from the browser.
  # GRAPHITE_URL = 'https://graphite.example.com'
  # GRAPHITE_USER = 'graphite_user'
  # GRAPHITE_PASSWORD = 'graphite_password'
  # # User will be redirected to detailed system overview dashboard
  # GRAFANA_DASHBOARD = (
  #     'https://graphite.example.com/grafana'
  #     '/dashboard/db/system-overview'
  # )

  MEDIA_ROOT = "${mediaRoot}"
  STATIC_ROOT = "${staticRoot}"

  # Additional overrides
  ${appendConfig}
  '';
in
python3Packages.buildPythonPackage rec {

   pname = "serveradmin";
   version = "v1.7.0";

  src = fetchFromGitHub {
    owner = "innogames";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "17a1lk9q7hf4gg1ksqh1fw0kaprni7n8fpcg8hya3pk2jb0ssfvn";
  };

  django_postgresql_netfields = python3Packages.callPackage ./django-postgresql-netfields.nix {};

  pythonPath = with python3Packages; [
    django
    django_extensions
    django_postgresql_netfields
    jinja2
    netaddr
    paramiko
    pexpect
    pillow
    psycopg2
  ];

  propagatedBuildInputs = pythonPath;

  postInstall = ''
    mkdir -p $out/etc/serveradmin
    tee -a $out/etc/serveradmin/settings.py < ${(writeText "config.serveradmin" configText)}
  '';

  doInstallCheck = false;
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A central server database management system";
    homepage = https://github.com/innogames/serveradmin;
    license = licenses.mit;
    maintainers = with maintainers; [ seqizz ] ;
    platforms = platforms.linux;
  };
}
