FROM alpine:latest as builder

WORKDIR /usr/src

RUN apk add --no-cache \
      binutils \
      build-base \
      readline-dev \
      openssl-dev \
      ncurses-dev \
      git \
      cmake \
      gnu-libiconv \
      zlib-dev \
    && git clone --recurse-submodules https://github.com/SoftEtherVPN/SoftEtherVPN.git \
    && cd SoftEtherVPN \
    && ./configure \
    && make -C tmp \
    && make -C tmp install \
    && tar -czf /artifacts.tar.gz /usr/local

FROM alpine:latest

MAINTAINER EgoFelix <docker@egofelix.de>

WORKDIR /

COPY --from=build /artifacts.tar.gz .

RUN apk add --no-cache \
      ca-certificates \
      iptables \
      readline \
      gnu-libiconv \
      zlib \
    && tar xfz artifacts.tar.gz \
    && rm artifacts.tar.gz \
    && mkdir /etc/vpnserver \
    && touch /etc/vpnserver/vpn_server.config \
    && ln -sf /etc/vpnserver/vpn_server.config /usr/local/libexec/softether/vpnserver/vpn_server.config \
    && mkdir -p /var/log/vpnserver/packet_log /var/log/vpnserver/security_log /var/log/vpnserver/server_log \
    && ln -sf /var/log/vpnserver/packet_log /usr/local/libexec/softether/vpnserver/packet_log \
    && ln -sf /var/log/vpnserver/security_log /usr/local/libexec/softether/vpnserver/security_log \
    && ln -sf /var/log/vpnserver/server_log /usr/local/libexec/softether/vpnserver/server_log

ENTRYPOINT ["vpnserver"]
