{
  config,
  lib,
  pkgs,
  ...
}:
let
  etc' = lib.attrValues config.environment.etc;
in
{
  options = {
    environment.etc = lib.mkOption {
      default = { };
      description = ''
        Set of files that have to be linked in {file}`/etc`.
      '';

      type =
        with lib.types;
        attrsOf (
          submodule (
            {
              name,
              config,
              options,
              ...
            }:
            {
              options = {
                target = lib.mkOption {
                  type = lib.types.str;
                  description = ''
                    Name of symlink (relative to
                    {file}`/etc`).  Defaults to the attribute
                    name.
                  '';
                };

                text = lib.mkOption {
                  default = null;
                  type = lib.types.nullOr lib.types.lines;
                  description = "Text of the file.";
                };

                source = lib.mkOption {
                  type = lib.types.path;
                  description = "Path of the source file.";
                };
              };

              config = {
                target = lib.mkDefault name;
                source = lib.mkIf (config.text != null) (
                  let
                    name' = "etc-" + lib.replaceStrings [ "/" ] [ "-" ] name;
                  in
                  lib.mkDerivedConfig options.text (pkgs.writeText name')
                );
              };
            }
          )
        );
    };
  };

  config = {
    system.build.etcBasedir = pkgs.runCommandLocal "etc-lowerdir" { } ''
      set -euo pipefail

      makeEtcEntry() {
        src="$1"
        target="$2"

        mkdir -p "$out/$(dirname "$target")"
        cp "$src" "$out/$target"
      }

      mkdir -p "$out"
      ${lib.concatMapStringsSep "\n" (
        etcEntry:
        lib.escapeShellArgs [
          "makeEtcEntry"
          # Force local source paths to be added to the store
          "${etcEntry.source}"
          etcEntry.target
        ]
      ) etc'}
    '';

    system.build.etcMetadataImage =
      let
        etcJson = pkgs.writeText "etc-json" (builtins.toJSON etc');
        etcDump = pkgs.runCommand "etc-dump" { } ''
          ${lib.getExe pkgs.buildPackages.python3} ${./build-composefs-dump.py} ${etcJson} > $out
        '';
      in
      pkgs.runCommand "etc-metadata.erofs"
        {
          nativeBuildInputs = with pkgs.buildPackages; [
            composefs
            erofs-utils
          ];
        }
        ''
          mkcomposefs --from-file ${etcDump} $out
          fsck.erofs $out
        '';
  };

}
