{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    fonts.packages = [
      pkgs.iosevka
    ];

    environment = {
      etc = {
        "foo.conf".text = ''
          launch_the_rockets = true
        '';
      };
    };
  };
}
