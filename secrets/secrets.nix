let
  jonas-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+pzjmsotqutUKGBpYBWyvyH1wQZJ/a4rOHaghaaCG/ jonas@nixos-l540";
  jonas-vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYL1ifWNX2y80O0Sk4OnKZIDJ3Y7dXVRtNcmCkusXuS jonas@vetus";
  users = [jonas-l540 jonas-vetus];

  nixos-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1Jl4Nss6OmOtm60n/Jm6/9yk0/O0RKiQe6YMa8LcPn root@nixos-l540";
  vetus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ24D0+0CdFHLHhMGs11dqvOhEnh7xSf7sxzdSpu47Lp root@vetus";
  systems = [nixos-l540 vetus];
in {
  "vpn-credentials.age".publicKeys = users ++ systems;
  "vpn-config.age".publicKeys = users ++ systems;
}
