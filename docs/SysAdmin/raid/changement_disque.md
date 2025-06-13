# SoftRaid: Changement de disque sur la machine de prod

=> Procédure que j'avais écrite pour le [parti pirate](https://sources.partipirate.org/ektek/documentation-technique/-/blob/main/docs/infra/procedures/changement_disque.md) et que je remets ici pour mes archives personnelles.

License: [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/)

## Vérifier le status SMART

Exemple de disque à changer:

> === START OF INFORMATION SECTION ===  
Model Family:     Samsung based SSDs  
Device Model:     SAMSUNG MZ7LN512HMJP-00000  
Serial Number:    S2MHNX0H409077  
LU WWN Device Id: 5 002538 d40db8e84  
Firmware Version: MAV0100Q  
User Capacity:    512,110,190,592 bytes [512 GB]  
Sector Size:      512 bytes logical/physical  
Rotation Rate:    Solid State Device  
Form Factor:      2.5 inches  
TRIM Command:     Available  
Device is:        In smartctl database 7.3/5319  
ATA Version is:   ACS-2, ATA8-ACS T13/1699-D revision 4c  
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)  
Local Time is:    Fri May 30 22:42:34 2025 CEST  
SMART support is: Available - device has SMART capability.  
SMART support is: Enabled  
>
> === START OF READ SMART DATA SECTION ===  
SMART overall-health self-assessment test result: FAILED!  
Drive failure expected in less than 24 hours. SAVE ALL DATA.  
See vendor-specific Attribute list for failed Attributes.  

## Etapes:

### Eteindre les VM sur Proxmox
```bash
qm list
qm stop 104
qm stop 105
qm stop 106
[...]
```

### Eteindre la machine
```bash
shutdown -P now
```

### envoyer un mail au support 

```
Bonjour,

Je me permets d'ouvrir ce ticket car nous avons eu une erreur smart sur l'un des 3 disques de notre raid5. Le dernier disque a besoin lui aussi d'être changé.
=== START OF INFORMATION SECTION ===
Model Family:     Samsung based SSDs
Device Model:     SAMSUNG MZ7LN512HMJP-00000
Serial Number:    S2MHNX0H409077
LU WWN Device Id: 5 002538 d40db8e84
Firmware Version: MAV0100Q
User Capacity:    512,110,190,592 bytes [512 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
TRIM Command:     Available
Device is:        In smartctl database 7.3/5319
ATA Version is:   ACS-2, ATA8-ACS T13/1699-D revision 4c
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Fri May 30 22:42:34 2025 CEST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: FAILED!
Drive failure expected in less than 24 hours. SAVE ALL DATA.
See vendor-specific Attribute list for failed Attributes.

Nous avons pris le soin de faire des backup. Vous pouvez changer le disque quand vous le souhaitez.

Cordialement,

Ambre pour l'équipe technique du parti pirate
```

### Une fois le disque changé, redémarrer en mode rescue

- On passe en root
```bash
sudo -i
```
- On vérifie qu'on a bien des raids de présent:
```bash
cat /proc/mdstat
```
```
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md126 : inactive sdc3[4](S) sdb3[3](S)
      997853872 blocks super 1.2

md127 : inactive sdc2[4](S) sdb2[3](S)
      1046528 blocks super 1.2

unused devices: <none>
```

- Une fois connecté, on vérifie que notre disque est bien présent:
```bash
parted -l
```
```
[sudo] password for partipirate:
Error: /dev/sda: unrecognised disk label
Model: ATA SAMSUNG MZ7LH512 (scsi)
Disk /dev/sda: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: unknown
Disk Flags:

Model: ATA SAMSUNG MZ7LN512 (scsi)
Disk /dev/sdb: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size   Type     File system  Flags
 1      1049kB  537MB   536MB  primary
 2      537MB   1074MB  537MB  primary               boot, raid
 3      1074MB  512GB   511GB  primary               raid


Model: ATA SAMSUNG MZ7LH512 (scsi)
Disk /dev/sdc: 512GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos
Disk Flags:

Number  Start   End     Size   Type     File system  Flags
 1      1049kB  537MB   536MB  primary
 2      537MB   1074MB  537MB  primary               raid
 3      1074MB  512GB   511GB  primary               raid
```

- On formate le disque en question en prenant exemple sur un autre disque (sda = disque a formater; sdc = disque à prendre en exemple):
```
root@163-172-54-138:~# sfdisk -d /dev/sdc | sfdisk /dev/sda
```
```
Checking that no-one is using this disk right now ... OK

Disk /dev/sda: 476.94 GiB, 512110190592 bytes, 1000215216 sectors
Disk model: SAMSUNG MZ7LH512
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x8805f5ac.
/dev/sda1: Created a new partition 1 of type 'Linux' and of size 511 MiB.
/dev/sda2: Created a new partition 2 of type 'Linux raid autodetect' and of size 512 MiB.
/dev/sda3: Created a new partition 3 of type 'Linux raid autodetect' and of size 475.9 GiB.
/dev/sda4: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x8805f5ac

Device     Boot   Start        End   Sectors   Size Id Type
/dev/sda1          2048    1048575   1046528   511M 83 Linux
/dev/sda2       1048576    2097151   1048576   512M fd Linux raid autodetect
/dev/sda3       2097152 1000215215 998118064 475.9G fd Linux raid autodetect

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

- On rajoute notre disque au raid (remplacer sda3 par le nouveau disque et md1 par le raid):
```bash
# Raid de données
mdadm --add /dev/md1 /dev/sda3
# Raid de boot
mdadm --add /dev/md127 /dev/sda2
```

- On vérifie que la reconstruction est bien en cours:
```bash
cat /proc/mdstat
```

```
Personalities : [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid5 sda3[5] sdb3[3] sdc3[4]
      997853184 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [_UU]
      [=========>...........]  recovery = 46.0% (229767936/498926592) finish=21.6min speed=206968K/sec
      bitmap: 0/4 pages [0KB], 65536KB chunk

md127 : inactive sdc2[4](S) sdb2[3](S)
      1046528 blocks super 1.2

unused devices: <none>
```


## En cas de souci pour démarrer normalement

> **On fait les mêmes étapes mais en rescue (au moins pour la partition /boot).**

En plus, on va faire un chroot pour reconstruire le grub:

```bash
mount -v /dev/md126 /mnt/
# mount: /dev/md126 mounted on /mnt.
mount -v /dev/md127 /mnt/boot/
# mount: /dev/md127 mounted on /mnt/boot.

mount -v -t proc proc /mnt/proc/
# mount: proc mounted on /mnt/proc.
mount -v -t sysfs sys /mnt/sys/
# mount: sys mounted on /mnt/sys.
mount -v -o bind /dev /mnt/dev/
# mount: /dev bound on /mnt/dev.
mount -v -t devpts pts /mnt/dev/pts/
# mount: pts mounted on /mnt/dev/pts.

# chroot /mnt /bin/bash
```

puis:
```bash
update-grub

grub-install /dev/sda3
```

## Redémarer les VM

Redémarrer dans cette ordre:

- VPN (`qm list` puis `qm start id`)
- mail
- ppfr-prod
- discourse
- test
