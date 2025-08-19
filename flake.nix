{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    {
      systemConfigs.cfg =
        let
          systemLayer = import ./lib {
            inherit nixpkgs;
          };
        in
        systemLayer.makeSystemLayer {
          modules = [
            ./configuration.nix
          ];
        };

      systemConfigs.default =
        let
          systemLayer = import ./lib {
            inherit nixpkgs;
          };
        in
        (systemLayer.makeSystemLayer {
          modules = [
            ./configuration.nix
          ];
        }).config.system.build.etcMetadataImage;

      packages.x86_64-linux.activate =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.writeShellScriptBin "activate" ''
          store_path=$(nix \
            --experimental-features 'nix-command flakes' \
            build --no-link --print-out-paths $1)
          echo $store_path

          sudo mkdir -p /nix/var/nix/gcroots/nix-system-layer
          #    ln -sfn
          sudo ln --symbolic --force --no-dereference $store_path /nix/var/nix/gcroots/nix-system-layer/current
        '';

      packages.x86_64-linux.default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          fonts = [
            pkgs.iosevka
            pkgs.nerd-fonts.symbols-only
            # pkgs.fira-code
          ];
          nix-system-layer-conf =
            font-pkgs:
            pkgs.writeText "00-nix-system-layer.conf" ''
              <?xml version='1.0'?>
              <!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
              <fontconfig>
                ${pkgs.lib.concatStringsSep "\n" (map (font: "<dir>${font}</dir>") font-pkgs)}
              </fontconfig>
            '';
        in
        pkgs.runCommand "fonts" { } ''
          echo "My example command is running"

          mkdir -p $out/etc/systemd/system

          mkdir -p $out/etc/fonts/conf.d
          #touch $out/etc/fonts/conf.d/00-nix-system-layer.conf
          ln -s "${nix-system-layer-conf fonts}" $out/etc/fonts/conf.d/00-nix-system-layer.conf
        '';
    };
}
