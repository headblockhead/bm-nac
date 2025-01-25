{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        rec {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nasm
              xc
              xxd
              qrencode
              zbar
            ];
          };
          packages.saycheese-ncg = pkgs.stdenv.mkDerivation {
            name = "saycheese-ncg";
            src = ./.;

            nativeBuildInputs = [ pkgs.nasm ];

            buildPhase = ''
              runHook preBuild
              nasm -f bin -o main.o src/main.asm
              chmod +x main.o
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp main.o $out/bin/saycheese-ncg
              runHook postInstall
            '';
          };
          packages.default = packages.saycheese-ncg;
        }
      );
}
