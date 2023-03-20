let
  jonas = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCeGl3iejHE7wcUwm6xQMHN0zrZepiNzME3ytWcI+qX+gL8qPf9uWY3f6h9WSPRX+dKVlH0sVgdJKD7ZktuN38Dr1m8N1/6KV5V0P7xY/oOki/+10g+4+KP12cGHsNanAIy1FzzKxnXiXsWCEH0uSo07tixJe5kghQMfqiHP6WF+bwBW5BjCy9sIPHRB0jlW39hxWsjSaERWagBILaWxq6cFYlMZwA8vsZPgTI87KJ5HVeacYWgYv4nX+c/XLc0O3qsdOhqaPyEHyoo2BZdgBXZu+vH4vhRML/reRSF9WVY/GBgE+902GspoE3uJ9UzF/ph0YbHdCMHiuF8W0glAOmPUH+w9+yJsSnBpnWb+z0O5wTl3yzjr5PO4KqQyZOxrvHJ+jwhnBFjjJrvaSouyb8rNgjqSDfiBQtXpVcTUBszCC1LTlQUKa0StQ9bFLtKBVZ9wq+wg4uqATQPDLNTCLWLlHnE1uechnaMkRa/nnW3mUuZHmGhAHKpaACyzKNsNC8= jonas@nixos-l540";
  users = [ jonas ];

  nixos-l540 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN1Jl4Nss6OmOtm60n/Jm6/9yk0/O0RKiQe6YMa8LcPn root@nixos-l540";
  systems = [ nixos-l540 ];
in
{
  "vpn-credentials.age".publicKeys = users ++ systems;
  "vpn-config.age".publicKeys = users ++ systems;
}
