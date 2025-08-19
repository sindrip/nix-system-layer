{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./etc.nix
    ./fonts.nix
  ];

  options = {
    system = lib.mkOption {
      default = { };
    };
  };
}
