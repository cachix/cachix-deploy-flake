{ lib, disks, ... }:
{
  disko.devices.disk = lib.genAttrs disks
    (disk: {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
            priority = 1;
          };
          ESP = {
            size = "500M";
            type = "EF00";
            content = {
              type = "mdraid";
              name = "boot";
            };
          };
          nixos = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "nixos";
            };
          };
        };
      };
    });
  disko.devices.mdadm = {
    boot = {
      type = "mdadm";
      level = 1;
      metadata = "1.0";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };
    nixos = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions.primary = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
