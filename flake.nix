{
  description = "Datadog pup CLI";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.2.2";

      srcs = {
        "x86_64-linux" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
          hash = "sha256-88dyPaIi9O7R9NaXyJoTn5YnS3A7h3c9d85mzCLLxq8=";
        };
        "aarch64-linux" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
          hash = "sha256-XQGaccTIlfsJHxWoq7RsLl9AHRpEnJMBdvNKc/Yd9eg=";
        };
        "x86_64-darwin" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
          hash = "sha256-8aatf2rO8PD+GA6/IwyzU9ncFZKTvNKgi513dnuh2R8=";
        };
        "aarch64-darwin" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
          hash = "sha256-tn/6ZNEqHwP0/zTLFwoKpjNqJPBBGJNHDxqIqKG3iEk=";
        };
      };

      supportedSystems = builtins.attrNames srcs;

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        f system nixpkgs.legacyPackages.${system}
      );
    in
    {
      packages = forAllSystems (system: pkgs:
        let
          src = srcs.${system};
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "pup";
            inherit version;

            src = pkgs.fetchurl {
              inherit (src) url hash;
            };

            sourceRoot = ".";

            nativeBuildInputs = [ pkgs.installShellFiles ];

            installPhase = ''
              install -Dm755 pup $out/bin/pup
            '';

            meta = {
              description = "Datadog CLI for managing Pipelines, Observability, and more";
              homepage = "https://github.com/DataDog/pup";
              license = pkgs.lib.licenses.asl20;
              platforms = supportedSystems;
              mainProgram = "pup";
            };
          };
        }
      );

      overlays.default = final: prev: {
        pup = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
