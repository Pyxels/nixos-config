# SSH public keys, shared by agenix recipients and authorized_keys.
{
  users = {
    jonas-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+pzjmsotqutUKGBpYBWyvyH1wQZJ/a4rOHaghaaCG/ jonas@nixos-l540";
    jonas-vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus";
    jonas-bits = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXebXmITS8OF3CLbwVC+HFRg8b/96FiEccvAfQV/ovZ jonas@jonas-bits";
  };

  hosts = {
    arm-vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLMDZFCA5FqnUaHSkIUt9+7u1f6xUwSwIXZ2j5kDV/c root@arm-vps";
    beelink = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnMRPNsqL8bVMlpSK/2YbcgWKosmWuoOEboOB8UniP root@beelink";
  };

  # allowed to log in as root on servers and the installer
  admins = with (import ./keys.nix).users; [jonas-bits jonas-vetus];
}
