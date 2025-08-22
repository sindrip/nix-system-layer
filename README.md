# Nix System Layer
Configure Ubuntu 25.04 on a system level.

Overlay etc ?

- Fonts
    - /etc/fonts/conf.d/00-nix-system-layer.conf
    - /etc/systemd/system/nix-system-layer{} ?


## Mounting example

```sh
tmpMetadataMount=$(TMPDIR="/run" mktemp --directory -t nixos-etc-metadata.XXXXXXXXXX)
sudo mount --type erofs --options ro,nodev,nosuid ./result/etcMetadataImage /run/etc-metadata.HA1GFvoSkn
sudo mount -t overlay -o lowerdir=/run/etc-metadata.HA1GFvoSkn,upperdir=/testdir,redirect_dir=on,metacopy=on,workdir=/testdir-work overlay /testdir
```

## Systemd mount
Copy the nixSystemLayerEtcMetadata.mount file to /etc/systemd/system and enable the unit. The metadata will be automatically mounted on startup.

Copy the etc.mount file to /etc/systemd/system and enable the unit. For now we are manually creating /.rw-etc (which should be moved to systemd)
