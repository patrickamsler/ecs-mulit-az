FROM --platform=linux/amd64 ubuntu:18.04

RUN apt-get update && apt-get install -y nginx

ADD nginx.conf /etc/nginx/nginx.conf
ADD index.html /www/data/

EXPOSE 80
CMD ["nginx"]