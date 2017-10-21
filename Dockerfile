FROM nginx:alpine
MAINTAINER Rafal Wolak <r.wolak@design4.pro> (@design4pro)

ENV DEBUG=false RAP_DEBUG="info"
ARG VERSION_RANCHER_DOCKER_GEN="artifacts/master"

RUN apk add --no-cache nano ca-certificates unzip wget certbot bash openssl

# Install Forego & rancher-docker-gen
ADD https://github.com/design4pro/forego/releases/download/v0.16.1/forego /usr/local/bin/forego

RUN wget "https://gitlab.com/design4pro/rancher-docker-gen/builds/$VERSION_RANCHER_DOCKER_GEN/download?job=compile-go" -O /tmp/rancher-docker-gen.zip \
	&& unzip /tmp/rancher-docker-gen.zip -d /usr/local/bin \
	&& chmod +x /usr/local/bin/rancher-gen \
	&& chmod u+x /usr/local/bin/forego \
	&& rm -f /tmp/rancher-docker-gen.zip

#Copying all templates and script
COPY /app/ /app/
WORKDIR /app/

# Seting up repertories & Configure Nginx and apply fix for very long server names
RUN chmod +x /app/letsencrypt.sh \
    && mkdir -p /etc/nginx/certs /etc/nginx/vhost.d /etc/nginx/conf.d /usr/share/nginx/html /etc/letsencrypt \
    && echo "daemon off;" >> /etc/nginx/nginx.conf \
    && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf \
    && chmod u+x /app/remove

ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh" ]
CMD ["forego", "start", "-r"]
