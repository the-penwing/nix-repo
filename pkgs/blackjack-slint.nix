{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  imagemagick,
  fontconfig,
  libxkbcommon,
  wayland,
  wayland-protocols,
  vulkan-loader,
  libglvnd,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  darwin,
}: let
  src = fetchFromGitHub {
    owner = "the-penwing";
    repo = "blackjack-slint";
    rev = "7ccf1b2f34bdc8af95d8a817187ff282ac536033";
    hash = "sha256-cG+YTsUBU2MZmxmFGYPiAwlAh1CsXu4DZyppDjgmaa8=";
  };

  isDarwin = stdenv.hostPlatform.isDarwin;

  desktopItem = makeDesktopItem {
    name = "blackjack-slint";
    desktopName = "Blackjack";
    comment = "Blackjack GUI built with Slint";
    exec = "blackjack-slint";
    icon = "blackjack-slint";
    categories = ["Game" "CardGame"];
    terminal = false;
  };

  linuxRuntimeLibs = [
    libxkbcommon
    wayland
    vulkan-loader
    fontconfig
    libglvnd
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  linuxBuildInputs = [
    fontconfig
    libxkbcommon
    wayland
    wayland-protocols
    vulkan-loader
    libglvnd
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  darwinBuildInputs = with darwin.apple_sdk.frameworks; [
    AppKit
    QuartzCore
    Metal
    Foundation
  ];
in
  rustPlatform.buildRustPackage {
    pname = "blackjack-slint";
    version = "0.1.0";

    inherit src;

    cargoLock.lockFile = "${src}/Cargo.lock";

    nativeBuildInputs =
      [pkg-config makeWrapper]
      ++ lib.optionals (!isDarwin) [copyDesktopItems imagemagick];
    desktopItems = lib.optionals (!isDarwin) [desktopItem];

    buildInputs =
      if isDarwin
      then darwinBuildInputs
      else linuxBuildInputs;

    doCheck = false;
    stripAllList = ["bin"];

    postInstall = ''
      mkdir -p $out/share/blackjack-slint
      cp -r ${src}/assets $out/share/blackjack-slint/assets

      ${lib.optionalString (!isDarwin) ''
        mkdir -p $out/share/icons/hicolor/256x256/apps
        magick ${src}/assets/cards/spades-1.png \
          -filter point \
          -resize 256x256 \
          -gravity center \
          -background none \
          -extent 256x256 \
          $out/share/icons/hicolor/256x256/apps/blackjack-slint.png
      ''}

      wrapProgram $out/bin/blackjack-slint \
        --set BLACKJACK_ASSETS_DIR $out/share/blackjack-slint/assets \
        ${lib.optionalString (!isDarwin) ''
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath linuxRuntimeLibs}:/run/opengl-driver/lib"
      ''}
    '';

    meta = {
      description = "Blackjack GUI built with Slint";
      homepage = "https://github.com";
      platforms = lib.platforms.unix;
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
