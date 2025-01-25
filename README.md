# BM-NAC
<sup>pronounced: bee-em-nack, stands for: beautiful-minimal-noughts-and-crosses</sup>

A noughts and crosses (tic-tac-toe) game for the Linux terminal written in assembly language, and designed to be both good-looking, and to produce a very small binary.

<pre>Welcome to Noughts and Crosses.
To select a square, choose the square&apos;s number from left to right, top to bottom. (1-9)
X&apos;s move: 7
-------------------
|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|
|<span style="background-color:#AA0000"><font color="#FFFFFF">  X  </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">  O  </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">  X  </font></span>|
|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|
-------------------
|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|
|<span style="background-color:#0000AA"><font color="#FFFFFF">  O  </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">  X  </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">  O  </font></span>|
|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|<span style="background-color:#0000AA"><font color="#FFFFFF">     </font></span>|
-------------------
|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|     |     |
|<span style="background-color:#AA0000"><font color="#FFFFFF">  X  </font></span>|  _  |  _  |
|<span style="background-color:#AA0000"><font color="#FFFFFF">     </font></span>|     |     |
-------------------
Game over.
Won by: X
</pre>

## Tasks

### run

```bash
nix build
ls -l ./result/bin/saycheese-ncg
./result/bin/saycheese-ncg
```

### qr

```bash
qrencode -t ansiutf8 -8 -r result/bin/saycheese-ncg
```
