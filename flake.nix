{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "ziczaczoe";
          src = self;
          nativeBuildInputs = [ pkgs.zig.hook ];
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ zig zls ];
        };
      };
    };
}
