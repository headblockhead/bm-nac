# BM-NAC
<sup>pronounced: bee-em-nack, stands for: beautiful-minimal-noughts-and-crosses</sup>

A noughts and crosses (tic-tac-toe) game for the Linux terminal written in assembly language, and designed to be both good-looking, and to produce a very small binary.

![screenshot](./screenshot.png)

## Tasks

> [!IMPORTANT]
> You must be in the `nix develop` shell for these tasks to work.

### build

```bash
nix build
ls -l ./result/bin/saycheese-ncg
```

### qr

```bash
qrencode -t ansiutf8 -8 -r result/bin/saycheese-ncg
qrencode -o qrcode.png -8 -r result/bin/saycheese-ncg
zbarimg --raw --oneshot -Sbinary qrcode.png > scanned-binary
diff -s result/bin/saycheese-ncg scanned-binary
```
