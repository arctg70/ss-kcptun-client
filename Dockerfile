FROM alpine:3.5

ENV SS_URL="https://github.com/shadowsocks/shadowsocks-libev/archive/v2.5.6.tar.gz" \
    SS_DIR=shadowsocks-libev-2.5.6 \
    CONF_DIR=/usr/local/conf \
    KCPTUN_URL="https://github.com/xtaci/kcptun/releases/download/v20170221/kcptun-linux-amd64-20170221.tar.gz" \
    KCPTUN_DIR=/usr/local/kcp-server

RUN apk add --no-cache pcre bash openssl s6 && \
    apk add --no-cache --virtual TMP autoconf automake build-base wget curl tar libtool linux-headers openssl-dev pcre-dev && \
# Install shadowsocks
    curl -sSL $SS_URL | tar xz && \
    cd $SS_DIR && \
    ./configure --disable-documentation && \
    make install && \
    cd .. && \
    rm -rf $SS_DIR && \
# Install kcptun
    mkdir -p ${CONF_DIR} && \
    mkdir -p ${KCPTUN_DIR} && cd ${KCPTUN_DIR} && \
    curl -sSL $KCPTUN_URL | tar xz -C ${KCPTUN_DIR}/ && \
    mv ${KCPTUN_DIR}/server_linux_amd64 ${KCPTUN_DIR}/kcp-server && \
    rm -f ${KCPTUN_DIR}/client_linux_amd64 && \
    chown root:root ${KCPTUN_DIR}/* && \
    chmod 755 ${KCPTUN_DIR}/* && \
    ln -s ${KCPTUN_DIR}/* /bin/ && \
# Install sshd
    apk add --no-cache openssh && \
    ssh-keygen -A && \
# Install nload
    apk add --no-cache nload && \
# Clean up
    apk --no-cache del --virtual TMP && \
    apk --no-cache del build-base autoconf && \
    rm -rf /var/cache/apk/* ~/.cache

COPY run.sh /run.sh
COPY s6.d /etc/s6.d
RUN chmod +x /run.sh /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
CMD ["/run.sh"]
