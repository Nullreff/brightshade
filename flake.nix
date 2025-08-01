{
  description = "Data multitool built on shaders";

  inputs = {
    nixpkgs.url     = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs    = nixpkgs.legacyPackages.${system};
      libPath = with pkgs; lib.makeLibraryPath [];
    in
    {
      devShells.default = pkgs.mkShell rec {
        packages          = with pkgs; [ alsa-lib.dev ];
        buildInputs       = with pkgs; [ clang llvmPackages.bintools rustup ];
        nativeBuildInputs = [ pkgs.pkg-config ];

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (packages ++ buildInputs ++ nativeBuildInputs);
        RUSTC_VERSION   = "beta";
        LIBCLANG_PATH   = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];
        RUSTFLAGS       = (builtins.map (a: ''-L ${a}/lib'') []);

        BINDGEN_EXTRA_CLANG_ARGS = (builtins.map (a: ''-I"${a}/include"'') [ pkgs.glibc.dev ]) ++ [
          ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
          ''-I"${pkgs.glib.dev}/include/glib-2.0"''
          ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
        ];

        shellHook = ''
          export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
          export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';
      };
    }
  );
}
