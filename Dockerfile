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
      zlib-dev
RUN git clone --recurse-submodules https://github.com/SoftEtherVPN/SoftEtherVPN.git

RUN cd SoftEtherVPN \
    && ./configure \
    && make -C build

FROM alpine:latest

MAINTAINER EgoFelix <docker@egofelix.de>

WORKDIR /

RUN apk add --no-cache \
      ca-certificates \
      iptables \
      readline \
      gnu-libiconv \
      zlib \
    && mkdir -p /opt/softether/

ENV LD_LIBRARY_PATH /opt/softether

# Install Binaries
COPY --from=builder /usr/src/SoftEtherVPN/build/libcedar.so /usr/src/SoftEtherVPN/build/libmayaqua.so /usr/src/SoftEtherVPN/build/vpnserver /usr/src/SoftEtherVPN/build/vpncmd /usr/src/SoftEtherVPN/build/libcedar.so /usr/src/SoftEtherVPN/build/libmayaqua.so /usr/src/SoftEtherVPN/build/hamcore.se2 /opt/softether/

ENTRYPOINT ["/opt/softether/vpnserver", "execsvc"]
