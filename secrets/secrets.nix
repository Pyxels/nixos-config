let
  jonas-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+pzjmsotqutUKGBpYBWyvyH1wQZJ/a4rOHaghaaCG/ jonas@nixos-l540";
  users = [ jonas-l540 ];

  nixos-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1Jl4Nss6OmOtm60n/Jm6/9yk0/O0RKiQe6YMa8LcPn root@nixos-l540";
  systems = [ nixos-l540 ];
in
{
  "vpn-credentials.age".publicKeys = users ++ systems;
  "vpn-config.age".publicKeys = users ++ systems;
}
