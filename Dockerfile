FROM centos:6@sha256:12f2e9aa55e245664e86bfdf4eb000ddc316b48d9aa63c3c98ba886416868e49

RUN curl -fsSLO https://raw.githubusercontent.com/cms-sw/cms-docker/master/slc6/RPM-GPG-KEY-cern \
    && rpm --import RPM-GPG-KEY-cern \
    && rm RPM-GPG-KEY-cern \
    && curl -fsSL -o /etc/yum.repos.d/slc6-scl.repo http://linuxsoft.cern.ch/cern/scl/slc6-scl.repo \
    && yum install -y \
          curl \
          devtoolset-3-gcc-c++ \
          fftw-devel \
          git \
          make \
          libpng-devel \
          libtiff-devel \
          python27-numpy.x86_64 \
          zlib-devel \
    && yum clean packages \
    && rm -rf /var/cache/yum/*

# Download and compile mrtrix3.
WORKDIR /tmp
ARG mrtrix3_version="master"
ARG NPROC=1
ENV MRTRIX3_VERSION=$mrtrix3_version
RUN if [ -z "$mrtrix3_version" ]; then \
        echo "ERROR: mrtrix3_version not defined" && exit 1; \
    fi \
    && curl -fsSL https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz \
    | tar xz \
    && git clone https://github.com/MRtrix3/mrtrix3.git \
    && cd mrtrix3 \
    && git checkout "$mrtrix3_version" \
    && source /opt/rh/devtoolset-3/enable \
    && source /opt/rh/python27/enable \
    && EIGEN_CFLAGS="-isystem /tmp/eigen-3.3.7" ./configure -nogui \
    && echo "Compiling MRtrix3 ..." \
    && NUMBER_OF_PROCESSORS="$NPROC" ./build

WORKDIR /tmp/mrtrix3
# This returns non-zero even though successful
RUN yes | ./package_mrtrix -standalone || echo "Exit code $?"
WORKDIR /work
RUN tar czf "mrtrix3-${MRTRIX3_VERSION}-Linux-centos6-x86_64.tar.gz" -C /tmp/mrtrix3/_package mrtrix3
