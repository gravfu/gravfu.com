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