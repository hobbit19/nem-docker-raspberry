# Builds a Docker Image for Raspberry Pi with OpenJDK build on Resin OS
# Based on NEM Script for Dockerfile https://github.com/rb2nem/nem-docker
FROM resin/raspberry-pi-openjdk
MAINTAINER ixidion
#RUN dnf -y install java-1.8.0-openjdk-headless.x86_64 tar tmux supervisor procps jq unzip gnupg.x86_64
#RUN dnf -y upgrade nss

#WORKDIR /tmp

# Prepare Environment
RUN \
    apt-get -y update && \
    apt-get -y install jq procps supervisor tmux libnss3

# Download Nem, check signature and extract
RUN \
    version=$(curl -s http://bob.nem.ninja/version.txt) && \
    curl http://bob.nem.ninja/nis-ncc-$version.tgz > nis-ncc-$version.tgz && \
    sha=$(curl -s http://bigalice3.nem.ninja:7890/transaction/get?hash=$(curl -s  http://bob.nem.ninja/nis-ncc-$version.tgz.sig | grep txId | sed -e 's/txId: //') | jq -r '.transaction.message.payload[10:]') && \
    echo "$sha nis-ncc-$version.tgz"  > /tmp/sum && \
    sha256sum -c /tmp/sum && \
    tar zxf nis-ncc-$version.tgz

RUN useradd --uid 1000 nem
RUN mkdir -p /home/nem/nem/ncc/
RUN mkdir -p /home/nem/nem/nis/
RUN chown nem /home/nem/nem -R

# Cleanup temp
#RUN rm -Rf /tmp/*

#WORKDIR /home/nem

# servant
RUN \
    curl -L https://github.com/rb2nem/nem-servant/raw/master/servant.zip > servant.zip && \
    unzip servant.zip &&


# the sample is used as default config in the container
COPY ./custom-configs/supervisord.conf.sample /etc/supervisord.conf
# wallet
EXPOSE 7777
# NIS
EXPOSE 7890
# servant
EXPOSE 7880
# NCC
EXPOSE 8989

#User nem
CMD ["/usr/bin/supervisord"]
