{ stdenv, fetchFromGitHub }:
{
  sddm-rocket = stdenv.mkDerivation rec {
    pname = "sddm-rocket";
    version = "v1.0";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/${pname}
    '';
    src = fetchFromGitHub {
      owner = "hant-hub";
      repo = "BasicRocketTheme";
      rev = "${version}";
      sha256 = "HJAeOuIQK9jo2ti/JWsaMyE+qLWq1RRHXiP+cmnMLZE=";
    };
  };
}
