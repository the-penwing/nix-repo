{
  lib,
  fetchCrate,
  rustPlatform,
}: let
  src = fetchCrate {
    pname = "blackjack-rs";
    version = "0.4.0";
    sha256 = "sha256-bRrmznoG1GNXACtPMCG2deoo6rqvrDItziTvh4LHbVE=";
  };
in
  rustPlatform.buildRustPackage {
    pname = "blackjack-rs";
    version = "0.4.0";

    inherit src;

    cargoHash = "sha256-ej7q80OtB6+jYT0fcoXRQgqd5aFLBoexXoDNXDiBlvQ=";
    doCheck = false;
    stripAllList = ["bin"];

    meta = {
      description = "Blackjack for the terminal - Written in Rust";
      homepage = "https://github.com/the-penwing/blackjack-rs";
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
