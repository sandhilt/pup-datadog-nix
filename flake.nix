{
  description = "Datadog pup CLI";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "1.2.1";

      srcs = {
        "x86_64-linux" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
          hash = "sha256-ySznfbFr7m5jIGx3nFPROLHH1Zg/TWg0nx48ExGHo+Q=";
        };
        "aarch64-linux" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_arm64.tar.gz";
          hash = "sha256-BIkT3OuFx29C22DpBdAGAJyGlp5fTNFvqD9UDbhtnMQ=";
        };
        "x86_64-darwin" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Darwin_x86_64.tar.gz";
          hash = "sha256-VXfT/P3/YYhmTDLbv9JVhkoztx09uTl53WvMAhLJn+A=";
        };
        "aarch64-darwin" = {
          url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Darwin_arm64.tar.gz";
          hash = "sha256-NVhArSPMnt59lze0zbLfyDnZj5Xmc6rt42+BJ/oEw4c=";
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
