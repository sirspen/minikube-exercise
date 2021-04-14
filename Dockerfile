ARG alpine_version=3.13
ARG go_version=1.16.3

FROM golang:${go_version}-alpine${alpine_version}

ARG user=spencer-hello
ARG group=spencer-hello
ARG uid=1000
ARG gid=1000

RUN addgroup -S -g ${gid} ${group} && \
    adduser -S -G ${group} --u ${uid} -s /bin/bash ${user}

USER $user

COPY --chown=$user:$group src/ /go/src/app

WORKDIR /go/src/app

ENTRYPOINT ["go", "run", "spencer/hello"]
