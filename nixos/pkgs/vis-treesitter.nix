{ pkgs, stdenv }:
{
vis-treesitter = stdenv.mkDerivation {
        pname = "vis-treesitter";
        version = "v1.0";
        buildInputs = [
            pkgs.lua5_5
            pkgs.pkg-config
            pkgs.tree-sitter
        ];
        installPhase = ''
            runHook preInstall
            cd /tmp
            cp -r $src/* .
            export LUA_VERSION=5.5
            chmod +x ./build
            bash ./build

            mkdir -p $out
            cp ./* $out 
            runHook postInstall
            '';
        src = fetchGit {
            url = "https://codeberg.org/runitclean/vis-treesitter.git";
            rev = "24e73526b056acb8cb6bc9fee5704173bbb27ff2";
            ref = "main";
        };
    };
}
