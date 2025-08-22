{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    fonts = {
      packages = lib.mkOption {
        type = with lib.types; listOf path;
        default = [ ];
        example = lib.literalExpression "[ pkgs.dejavu_fonts ]";
        description = "List of primary font packages.";
      };
    };
  };

  config = {
    environment.etc."fonts/conf.d/00-nix-system-layer.conf".text = ''
      <?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
      <fontconfig>
        ${pkgs.lib.concatStringsSep "\n  " (map (font: "<dir>${font}</dir>") config.fonts.packages)}
      </fontconfig>
    '';
  };

}
