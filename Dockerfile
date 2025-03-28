FROM ensemblorg/ensembl-vep:release_113.4

ARG SAMTOOLSVER=1.14
ENV BCFTOOLS_VERSION=1.21
ENV BCFTOOLS_INSTALL_DIR=/opt/bcftools

USER root
# install dependencies and clean up apt garbage
RUN apt-get update && apt-get install --no-install-recommends -y \
 libncurses5-dev \
 libbz2-dev \
 liblzma-dev \
 libcurl4-gnutls-dev \
 zlib1g-dev \
 libssl-dev \
 ncurses-dev \
 gcc \
 g++ \
 wget \
 make \
 perl \
 bzip2 \
 gnuplot \
 ca-certificates \
 gawk && \
 apt-get autoclean && rm -rf /var/lib/apt/lists/*

# install loftee
WORKDIR /tools
RUN wget https://github.com/konradjk/loftee/archive/refs/tags/v1.0.4_GRCh38.tar.gz && \
  tar xvf v1.0.4_GRCh38.tar.gz 

# install LoFTK
WORKDIR /tools
RUN wget https://github.com/CirculatoryHealth/LoFTK/archive/refs/tags/v1.0.2.tar.gz && \
  tar xvf v1.0.2.tar.gz

# install bcftools
WORKDIR /tmp
RUN wget https://github.com/samtools/bcftools/releases/download/$BCFTOOLS_VERSION/bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  tar --bzip2 -xf bcftools-$BCFTOOLS_VERSION.tar.bz2 && \
  cd bcftools-$BCFTOOLS_VERSION && \
  make prefix=$BCFTOOLS_INSTALL_DIR && \
  make prefix=$BCFTOOLS_INSTALL_DIR install

WORKDIR /
RUN ln -s $BCFTOOLS_INSTALL_DIR/bin/bcftools /usr/bin/bcftools && \
  rm -rf /tmp/bcftools-$BCFTOOLS_VERSION

# install samtools, make /data
WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLSVER}/samtools-${SAMTOOLSVER}.tar.bz2 && \
 tar -xjf samtools-${SAMTOOLSVER}.tar.bz2 && \
 rm samtools-${SAMTOOLSVER}.tar.bz2 && \
 cd samtools-${SAMTOOLSVER} && \
 ./configure && \
 make && \
 make install && \
 mkdir /work

# set perl locale settings
ENV LC_ALL=C

WORKDIR /work
