{
  nixpkgs,
}:
{
  makeSystemLayer =
    {
      modules,
    # extraSpecialArgs ? { },
    }:
    {
      config =
        (nixpkgs.lib.evalModules {
          specialArgs = {
            pkgs = import nixpkgs { system = "x86_64-linux"; };
          };
          # } // extraSpecialArgs;
          modules = [
            ./modules
          ] ++ modules;
        }).config;

      topLevel =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.linkFarm "asdf" { };
    };
}
