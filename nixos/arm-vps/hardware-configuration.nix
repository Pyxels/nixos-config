{
  modulesPath,
  lib,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
    # /boot is a 253M ESP that cannot be grown (it sits before the root
    # partition). A kernel + initrd set is ~90M and install-grub copies the new
    # set before pruning old ones, so a limit of 2 needs 3 sets (~283M) at peak.
    configurationLimit = 1;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/43F7-29CD";
    fsType = "vfat";
  };
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
