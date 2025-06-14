FROM python:3.10-slim as builder
RUN apt update && apt install -y \
    git \
    libcairo2
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
COPY ./.git /app/.git
COPY ./docs /app/docs
COPY ./mkdocs.yml /app/mkdocs.yml
RUN mkdocs build

FROM nginx:alpine

COPY --from=builder /app/site /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

