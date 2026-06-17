FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# installs ping, netstat for debugging purposes
# installing tzdata will fix NESSUS_TZ_DIR related warning
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        iputils-ping \
        net-tools \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY Nessus-8.13.1-debian6_amd64.deb /tmp/Nessus.deb

RUN dpkg -i /tmp/Nessus.deb \
    && rm -f /tmp/Nessus.deb

# defaut Nessus Scanner port
EXPOSE 8834

ENTRYPOINT [ "/opt/nessus/sbin/nessusd" ]
# ENTRYPOINT [ "/etc/init.d/nessusd start" ]
