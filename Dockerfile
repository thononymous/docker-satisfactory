FROM ubuntu:22.04 AS suegit

# checkout sue
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends ca-certificates git && \
    git config --global url."https://github.com/".insteadOf git@github.com: && \
    git clone --recursive https://github.com/theAkito/sue.git /sue && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

## sue build container (gosu/su-exec replacement)
FROM nimlang/nim AS sue

COPY --from=suegit /sue /sue

WORKDIR /sue

RUN nimble check && \
    nimble --accept install --depsOnly && \
    nimble dbuild

## the service container
FROM steamcmd:ubuntu2204

# install palworld
RUN steamcmd +login anonymous +app_update 1690800 validate +quit

# install, i dunno sdk maybe?
# RUN steamcmd +login anonymous +app_update 1007 +quit 

USER root:root
ENV HOME=/root
ENV USER=root

# link save dir to top level for easy volume mounting
RUN <<EOF 
set -xeo pipefail
mkdir -p /home/sat/Steam/steamapps/common/SatisfactoryDedicatedServer/FactoryGame/
ln -s /saves /home/sat/Steam/steamapps/common/SatisfactoryDedicatedServer/FactoryGame/Saved
mkdir -p /home/sat/.config/Epic/FactoryGame/
ln -s /saves /home/sat/.config/Epic/FactoryGame/Saved
chown -R sat:sat /home/sat/
EOF

# install some deps
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends xdg-user-dirs xdg-utils && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# add built sue
COPY --from=sue /sue/sue /bin/sue

# add entrypoint
ADD docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-reuseconn"]

# vim: set ts=4 sw=4 expandtab:
