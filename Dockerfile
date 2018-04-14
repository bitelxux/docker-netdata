FROM alpine

# install
RUN apk add --no-cache gcc make autoconf automake
RUN apk add --no-cache g++
RUN apk add --no-cache alpine-sdk bash 
RUN apk add curl zlib-dev util-linux-dev 
RUN apk add libmnl-dev git 
RUN apk add pkgconfig python logrotate
RUN apk add --no-cache nodejs ssmtp
RUN git clone https://github.com/firehol/netdata.git --depth=1 && \
    cd netdata && \
    ./netdata-installer.sh --dont-wait --dont-start-it

# del dev tool
RUN apk del zlib-dev libmnl-dev gcc make git autoconf automake pkgconfig build-base alpine-sdk

# symlink access log and error log to stdout/stderr
RUN ln -sf /dev/stdout /var/log/netdata/access.log && \
    ln -sf /dev/stdout /var/log/netdata/debug.log && \
    ln -sf /dev/stderr /var/log/netdata/error.log

WORKDIR /

ADD run.sh /run.sh
RUN chmod +x /run.sh

# make data
RUN mv /usr/libexec/netdata /usr/libexec/netdata_start && mkdir /data && ln -sf /data /usr/libexec/netdata

ENV NETDATA_PORT=19999 SSMTP_TLS=YES SSMTP_SERVER=smtp.gmail.com SSMTP_PORT=587 SSMTP_HOSTNAME=localhost
EXPOSE $NETDATA_PORT

VOLUME /data
ENTRYPOINT ["/run.sh"]
