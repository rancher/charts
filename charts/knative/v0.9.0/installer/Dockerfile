# Looks like there is no official helm image,
# but we can borrow from https://github.com/helm/helm/blob/master/rootfs/Dockerfile
FROM alpine:3.7
COPY --from=gcr.io/kubernetes-helm/tiller:v2.11.0 /helm /usr/local/bin/helm
RUN apk update && apk add ca-certificates socat && rm -rf /var/cache/apk/*
# end base image :)

# Until we can rely on helm only we need to add kubectl (using any of these methods)
RUN apk update && apk add curl && rm -rf /var/cache/apk/* && \
  curl -sLS https://dl.k8s.io/v1.11.3/kubernetes-client-linux-amd64.tar.gz | tar -xvzf - -C /usr/local/bin/ --strip-components=3

RUN helm init --client-only

# found no support for file:// protocol
#COPY repo /repo
COPY knative /charts/knative

WORKDIR /charts

COPY installer/*.sh ./

# Also from https://github.com/helm/helm/blob/master/rootfs/Dockerfile
ENV HOME /tmp
USER nobody

ENTRYPOINT ["./install-knative.sh"]
