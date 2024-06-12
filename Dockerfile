FROM golang:1.22 AS builder

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl bzip2 git

RUN set -x \
  && git config --global http.postBuffer 1048576000 \
  && git config --global http.lowSpeedLimit 0 \
  && git config --global http.lowSpeedTime 999999

RUN set -x \
  && git clone https://github.com/kubedb/wal-g.git \
  && cd wal-g \
  && git checkout release-v2024.5.24 \
  && CGO_ENABLED=0 go build -v -o /wal-g ./main/sqlserver/main.go

FROM ubuntu:22.04

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl bzip2 git gpg nano fish

RUN apt-get install sudo nano wget curl gnupg gnupg1 gnupg2 -y
RUN apt-get install software-properties-common systemd vim -y
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

COPY --from=builder /wal-g /usr/bin/wal-g

RUN curl -o sqlcmd.bz2 -fsSL https://github.com/microsoft/go-sqlcmd/releases/download/v1.6.0/sqlcmd-v1.6.0-linux-amd64.tar.bz2 \
  && tar -xf sqlcmd.bz2 \
  && chmod +x sqlcmd \
  && cp sqlcmd /bin/sqlcmd

RUN curl -sSL https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -o /tmp/go1.22.4.linux-amd64.tar.gz \
  && tar -C /usr/local -xzf /tmp/go1.22.4.linux-amd64.tar.gz \
  && rm /tmp/go1.22.4.linux-amd64.tar.gz

RUN apt-get install sudo nano wget curl gnupg gnupg1 gnupg2 -y
RUN apt-get install software-properties-common systemd vim -y
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
RUN add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list)"
RUN apt-get update
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

RUN apt-get install -yq -y mssql-server
ENV PATH="/usr/local/go/bin:${PATH}"

ENTRYPOINT ["/lib/systemd/systemd"]