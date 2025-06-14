# Bonnes Pratiques SysAdmin

## Introduction
Ce document présente les bonnes pratiques à suivre pour les administrateurs systèmes afin d'assurer la sécurité, la performance et la fiabilité des systèmes informatiques.

## ... de base
### Suppression de fichiers
- Eviter recours à `rm -rf <dossier>`,
- utiliser `rmdir <dossier>` pour supprimer un dossier vide,
- utiliser des `../` pour remonter dans l'arborescence et éviter des erreurs de manipulation avec l'historique de la console. Eviter l'arborescence absolue.

### Commandes risquées
Procédure à suivre pour les commandes risquées:
```bash
[ "$variable" = yes ] && commande
```
Exemple pour un reboot
```bash
blablavar=yes
[ "$blablavar" = yes ] && systemctl reboot
```

### Utilisation de `screen`
Utiliser `screen` pour exécuter des commandes à distance et maintenir les sessions actives même en cas de déconnexion. Voici un exemple de création d'une session `screen`:
```bash
screen -S nom_de_la_session
```
#### Help
Pour obtenir de l'aide sur `screen`, vous pouvez utiliser la commande suivante:
ctrl + a puis
```bash
? # pour l'aide
```

### Ecoute Réseau

#### ip
Utiliser `ip` pour gérer les interfaces réseau. Voici quelques commandes utiles:
```bash
ip addr show # Afficher les adresses IP
ip link show # Afficher les interfaces réseau
ip route show # Afficher la table de routage
```
#### ifconfig
Utiliser `ifconfig` pour configurer les interfaces réseau. Bien que `ifconfig` soit obsolète, il est encore utilisé dans de nombreux systèmes. Voici un exemple de commande pour afficher les interfaces réseau:
```bash
ifconfig -a # Afficher toutes les interfaces réseau
```
#### netstat
Utiliser `netstat` pour afficher les connexions réseau, les tables de routage et les statistiques des interfaces. Voici quelques commandes utiles:
```bash
netstat -tuln # Afficher les ports d'écoute
netstat -an # Afficher toutes les connexions et ports
netstat -i # Afficher les statistiques des interfaces réseau
```
#### ss
Utiliser `ss` pour afficher les sockets et les connexions réseau. `ss` est plus rapide et plus efficace que `netstat`. Voici quelques exemples de commandes:
```bash
ss -tuln # Afficher les sockets d'écoute
ss -s # Afficher les statistiques des sockets
ss -p # Afficher les processus utilisant les sockets
```
#### nmap
Utiliser `nmap` pour scanner les ports et les services sur une machine ou un réseau. Voici un exemple de commande pour scanner les ports d'une adresse IP spécifique:
```bash
nmap -sS -p 1-65535 <ip> # Scanner tous les ports d'une adresse IP
```
#### ping
Utiliser `ping` pour tester la connectivité réseau. Voici un exemple de commande pour envoyer des paquets ICMP à une adresse IP spécifique:
```bash
ping -c 4 <ip> # Envoyer 4 paquets ICMP à une adresse IP
```
#### traceroute
Utiliser `traceroute` pour tracer le chemin des paquets vers une destination. Voici un exemple de commande pour tracer le chemin vers une adresse IP spécifique:
```bash
traceroute <ip> # Tracer le chemin vers une adresse IP
```
#### tcpdump
Utiliser `tcpdump` pour capturer et analyser le trafic réseau. Voici un exemple de commande pour capturer le trafic d'une adresse IP spécifique sur un port donné, tout en excluant le port 22 (SSH) pour éviter les interférences:
```bash
tcpdump -pni <interface> host <ip> and port <port> and not port 22
```
p: Mettre en mode "promiscuous" pour capturer tout le trafic
n: Spécifier l'interface réseau à écouter
i: Afficher les adresses IP au lieu des noms d'hôtes
