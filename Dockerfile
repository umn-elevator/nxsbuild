# ffmpeg - http://ffmpeg.org/download.html
#
# From https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
#
# https://hub.docker.com/r/jrottenberg/ffmpeg/
#
#
FROM        ubuntu:18.04 as base

FROM    base as build
WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yqq --no-install-recommends ca-certificates && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install curl unzip make autoconf automake cmake g++ gcc  && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install qt5-qmake qt5-default && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install libglew-dev && \
        rm -rf /var/lib/apt/lists/*

# ideally we would link this statically so we could drop QT.  But we don't actually know QT.
RUN     DIR=/tmp/nexus && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -L -o ${DIR}/nexus.tar.gz https://github.com/UMN-LATIS/nexus_update/archive/4.1.6.tar.gz && \
        tar -zxvf ${DIR}/nexus.tar.gz  && \
        curl -L -o ${DIR}/elevator.tar.gz https://github.com/UMN-LATIS/vcglib/archive/elevator.tar.gz && \
        tar -zxvf ${DIR}/elevator.tar.gz && \
        mv vcglib-elevator vcglib && \
        cd ${DIR}/nexus_update-4.1.6/src/nxsbuild && \
        qmake nxsbuild.pro && \
        make && \
        cd ${DIR}/nexus_update-4.1.6/src/nxsedit && \
        qmake nxsedit.pro && \
        make && \
        mv ${DIR}/nexus_update-4.1.6/bin/nxsbuild /usr/local/bin/nxsbuild && \
        mv ${DIR}/nexus_update-4.1.6/bin/nxsedit /usr/local/bin/nxsedit && \
        rm -rf ${DIR}

FROM    base as release

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install qt5-default  && \
        rm -rf /var/lib/apt/lists/*

COPY    --from=build /usr/local/bin/nxsbuild /usr/local/bin/nxsbuild
COPY    --from=build /usr/local/bin/nxsedit /usr/local/bin/nxsedit

# ADD     rti_runner /usr/local/bin/rti_runner.sh
# RUN     chmod a+x /usr/local/bin/rti_runner.sh

MAINTAINER  Colin McFadden <mcfa0086@umn.edu>
WORKDIR     /scratch/

# CMD         ["--help"]
ENTRYPOINT  ["nxsbuild"]
# ENV         LD_LIBRARY_PATH=/usr/local/lib

# Let's make sure the app built correctly
# Convenient to verify on https://hub.docker.com/r/jrottenberg/ffmpeg/builds/ console output