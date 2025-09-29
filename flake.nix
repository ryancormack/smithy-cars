{
  description = "Smithy CLI";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    platformMap = {
      "x86_64-linux" = {
        arch = "linux-x86_64";
        hash = "0nhaq0ng5sb9jfgxk33nnam5zs55ssjcmkaiaysclmnvy6bp4r6b";
      };
      "aarch64-linux" = {
        arch = "linux-aarch64";
        hash = "11z7j6nw8v6vgsi5psbl8cgfvi75621jb6xc38da4b77mdh0hfgg";
      };
      "x86_64-darwin" = {
        arch = "darwin-x86_64";
        hash = "0pizkn16aikzdp4jljqf71sv092gcnwggfzc3f09w24m0hhknkzb";
      };
      "aarch64-darwin" = {
        arch = "darwin-aarch64";
        hash = "0b82yq26nnjbv6c7h3nikh3903s56m440higkb8kbym26bgmrcn3";
      };
    };
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      platformInfo = platformMap.${system};
    in {
      packages.default = pkgs.stdenv.mkDerivation rec {
        name = "smithy";
        version = "1.62.0";

        src = pkgs.fetchurl {
          url = "https://github.com/smithy-lang/smithy/releases/download/${version}/smithy-cli-${platformInfo.arch}.zip";
          sha256 = platformInfo.hash;
        };

        nativeBuildInputs = [pkgs.unzip pkgs.jre];

        installPhase = ''
          mkdir -p $out
          cp -r * $out/

          if [ -f $out/bin/smithy ]; then
            # Patch Java paths for Nix environment
            sed -i 's|JAVA_HOME="\$APP_HOME"|JAVA_HOME="${pkgs.jre}"|' $out/bin/smithy
            sed -i 's|JAVACMD="\$JAVA_HOME/bin/java"|JAVACMD="${pkgs.jre}/bin/java"|' $out/bin/smithy
            sed -i 's|DEFAULT_JVM_OPTS=.*|DEFAULT_JVM_OPTS=""|' $out/bin/smithy
          else
            echo "Could not find smithy binary at bin/smithy"
            exit 1
          fi
        '';
      };

      devShells.default = pkgs.mkShell {
        packages = [self.packages.${system}.default];
      };

      formatter = pkgs.alejandra;
    });
}
