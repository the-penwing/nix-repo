{
  lib,
  stdenv,
  fetchgit,
  lua5_5,
  makeWrapper,
}: let
  src = fetchgit {
    url = "https://github.com/the-penwing/lua-dungeon-crawler.git";
    rev = "2c843c227d52a1f64d201dd7177fe4e99ed9e33a";
    sha256 = "sha256-08ycR8ziEWTyCtcgcioAIvu7LyT/vQWxYCY4xZ53Mv0=";
  };
in
  stdenv.mkDerivation {
    pname = "dungeon-crawler-cli";
    version = "0.1.0";

    inherit src;

    nativeBuildInputs = [makeWrapper];

    dontBuild = true;

    installPhase = ''
      mkdir -p $out/share/dungeon-crawler $out/bin
      cp -r ${src}/src/* $out/share/dungeon-crawler/

      makeWrapper ${lua5_5}/bin/lua $out/bin/dungeon-crawler-cli \
        --add-flags "$out/share/dungeon-crawler/main.lua" \
        --set LUA_PATH "$out/share/dungeon-crawler/?.lua;$out/share/dungeon-crawler/?/init.lua;;"
    '';

    meta = {
      description = "A CLI Dungeon Crawler written in Lua";
      license = lib.licenses.agpl3Only;
      maintainers = [
        {
          name = "Ben van Leeuwen";
          email = "thepenwing@gmail.com";
          github = "the-penwing";
        }
      ];
    };
  }
