# NixosOrivel

```
nixos-rebuild build-vm --flake .#orivel
QEMU_NET_OPTS='hostfwd=tcp:127.0.0.1:15557-:22' ./result/bin/run-orivel-vm
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 15557 -D 31746 root@127.0.0.1
```