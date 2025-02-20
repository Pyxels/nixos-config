let
  jonas-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+pzjmsotqutUKGBpYBWyvyH1wQZJ/a4rOHaghaaCG/ jonas@nixos-l540";
  jonas-vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus";
  jonas-bits = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILXebXmITS8OF3CLbwVC+HFRg8b/96FiEccvAfQV/ovZ jonas@jonas-bits";
  users = [jonas-l540 jonas-vetus jonas-bits];

  nixos-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1Jl4Nss6OmOtm60n/Jm6/9yk0/O0RKiQe6YMa8LcPn root@nixos-l540";
  vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ24D0+0CdFHLHhMGs11dqvOhEnh7xSf7sxzdSpu47Lp root@vetus";
  arm-vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLMDZFCA5FqnUaHSkIUt9+7u1f6xUwSwIXZ2j5kDV/c root@arm-vps";
  beelink = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQnMRPNsqL8bVMlpSK/2YbcgWKosmWuoOEboOB8UniP root@beelink";
  systems = [nixos-l540 vetus arm-vps beelink];
in {
  "attic-config.age".publicKeys = users ++ systems;
  "wanderer-meili-masterkey.age".publicKeys = users ++ [beelink];
  "wanderer-origin-url.age".publicKeys = users ++ [beelink];
}
