# Script de backup w/ rsync
(Ecrit le 26/12/2019)

### Base script
```
rm -rf backup.3
mv backup.2 backup.3
mv backup.1 backup.2
cp -al backup.0 backup.1
rsync -a --delete source_directory/ backup.0/
```
### Same thing but with Rsync directly:
```sh
rm -rf backup.3
mv backup.2 backup.3 
mv backup.1 backup.2 
mv backup.0 backup.1 
rsync -avh --delete --link-dest= backup.1/ source_directory/ backup.0/
```

Avantage de cette méthode :
- Si le fichier est le même, Rsync ne va pas le copier.
- Si le fichier est différent ou n'existe pas, copie.
- si fichier supprimé, suppression uniquement sur la backup en cours.
- chaque exact même fichier est backup qu'une seul fois.

=> On peux permettre aux gens en une commande ou via un logiciel de récupérer leurs dossiers en très peu de commande.  
=> En cas de stockage long terme, on peux faire une archive qui ne contiendra qu'une fois les fichiers.