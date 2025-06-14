# CSGO server optimization
(Ecrit le 03/09/2019)

## Linux Optimization

**(NOT NECESSARY ANYMORE, It was a source of many issues)**

A short list to do.
- Set sv_occlude_players to "0".
- Second use a tuned. -> <https://www.linuxsecrets.com/2892-tuned-for-linux-performance>
- Enable turbo for you processor. -> <https://forums.alliedmods.net/showpost.php?p=2577785&postcount=15>

Also check your Mhz cores. cat /proc/cpuinfo |grep "MHz" and see if it is set on higher freq

To test:
- Need to test:
  - Kernel (in Deutsch): <http://www.ulrich-block.de/tutorials/der-optimale-gameroot-und-gameserver-kernel/>
  - Liquorix
  - <https://xanmod.org/>

## CFG Optimization

```cfg
// 128 tick
sv_maxrate "0"
sv_minrate "196608"
sm_cvar sv_maxcmdrate "128"
sv_mincmdrate "128"
sv_minupdaterate "128"
sm_cvar sv_maxupdaterate "128"
```