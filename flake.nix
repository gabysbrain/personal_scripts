{
  description = "Personal scripts for productivity and automation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (system: { name = system; value = f system; }) systems);
      
      # List of scripts (add new scripts here without .sh extension)
      scripts = [
        "meeting_note"
      ];
      
      # Create a package for a script
      mkScriptPackage = pkgs: scriptName:
        pkgs.stdenv.mkDerivation {
          name = scriptName;
          src = ./bin;
          buildInputs = with pkgs; [ bash coreutils ];
          installPhase = ''
            mkdir -p $out/bin
            cp ${scriptName}.sh $out/bin/${scriptName}
            chmod +x $out/bin/${scriptName}
          '';
        };
      
      # Generate all packages for a system
      mkPackages = pkgs:
        builtins.listToAttrs (map
          (name: {
            inherit name;
            value = mkScriptPackage pkgs name;
          })
          scripts
        );
    in
    {
      packages = forAllSystems (system:
        mkPackages nixpkgs.legacyPackages.${system}
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              bash
              coreutils
              gawk
              fzf
              shellcheck
            ];
          };
        }
      );

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          packages = mkPackages pkgs;
        in
        builtins.listToAttrs (map
          (name: {
            inherit name;
            value = {
              type = "app";
              program = "${packages.${name}}/bin/${name}";
            };
          })
          scripts
        )
      );

      homeManagerModules.default = { config, lib, pkgs, ... }:
        with lib;
        {
          options.programs.ttw-scripts = {
            enable = mkEnableOption "personal scripts";
            vaultPath = mkOption {
              type = types.str;
              description = "Path to zettelkasten vault";
            };
          };

          config = mkIf config.programs.ttw-scripts.enable {
            home.packages = builtins.attrValues self.packages.${pkgs.system};
            home.sessionVariables.ZK_VAULT = config.programs.ttw-scripts.vaultPath;
          };
        };
    };
}
