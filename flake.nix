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
            ];
          };
          packages.saycheese = pkgs.stdenv.mkDerivation {
            name = "headblockhead-saycheese";
            src = ./.;

            nativeBuildInputs = [ pkgs.nasm ];

            buildPhase = ''
              runHook preBuild
              nasm -f elf64 -o main.o src/main.s
              ld -o main main.o
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              cp main $out/bin
                runHook postInstall
            '';
          };
          packages.default = packages.saycheese;
        }
      );
}
