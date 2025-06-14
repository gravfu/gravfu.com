# Build sur Docker

## Introduction
Ce document présente les étapes pour construire une image Docker à partir d'un Dockerfile. Il est destiné aux administrateurs systèmes et aux développeurs souhaitant automatiser le déploiement d'applications dans des conteneurs.
## Étapes de construction
### Créer un Dockerfile
#### Exemple de Dockerfile
Voici un exemple de Dockerfile simple :
   ```dockerfile
   FROM python:3.9-alpine
   COPY . /app
   WORKDIR /app
   CMD ["python3", "app.py"]
   ```
#### Construction multi-stage

```dockerfile
FROM maven:3.5-jdk-8-alpine as builder

COPY ./pom.xml ./pom.xml
RUN mvn dependency:resolve
COPY ./src ./src
RUN mvn package

FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=builder target/file.jar ./
CMD ["java", "-jar", "file.jar"]
```

### Construire l'image Docker &# Exécuter la commande de construction
```bash
# Lancer la construction de l'image
docker build -t <nom_de_l_image> .
# Exécuter un conteneur à partir de l'image
docker run -d --name <nom_du_conteneur> <nom_de_l_image>
```