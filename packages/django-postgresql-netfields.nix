{ stdenv
, buildPythonPackage
, django
, python3Packages
, fetchFromGitHub
}:

buildPythonPackage rec {
  version = "1.0.1";
  pname = "django-postgresql-netfields";

  src = fetchFromGitHub {
    owner = "jimfunk";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "0sz3y6cqk0yrra7w2nwfx2iiyy7k94idsvc6jmawym5z7vc8cffv";
  };

  # Failing because of ENV variables
  doCheck = false;

  propagatedBuildInputs = [
    django
    python3Packages.netaddr
  ];

  meta = with stdenv.lib; {
    description = "Django PostgreSQL netfields implementation";
    homepage = https://github.com/jimfunk/django-postgresql-netfields;
    license = licenses.bsd2;
  };
}
