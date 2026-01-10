{ stdenv, fetchFromGitHub }:
{
  sddm-themes.sddm-rocket = stdenv.mkDerivation rec {
    pname = "sddm-sugar-dark";
    version = "v1.2";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/${pname}
    '';
    src = fetchFromGitHub {
      owner = "hant-hub";
      repo = "BasicRocketTheme";
      rev = "${version}";
      sha256 = "7f576196a00159581e8641e263105661fec739fb";
    };
  };
}
