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
      pkgs.fira-code
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
