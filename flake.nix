{
  description = "Dev and build env for pdf-concat.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pname = "pdf-concat";
        version = "0.1.0";
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        nativeBuildInputs = with pkgs; [
          rustToolchain
          cargo-watch
          just
          lld
          nodejs_22
          parallel
          pkg-config
          wasm-pack
        ];

        buildInputs = with pkgs; [
          openssl
        ];

        pdfium = pkgs.fetchzip {
          url = "https://github.com/paulocoutinhox/pdfium-lib/releases/download/6694/wasm.tgz";
          hash = "sha256-1V0j58Vbe6dhM1LG9V6+yGKULllZHyK1rm1JVR2hrt8=";
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          inherit buildInputs nativeBuildInputs pdfium;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeBuildInputs;
          PDFIUM_PATH = pdfium;
        };
      }
    );
}
