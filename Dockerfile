FROM centos:6@sha256:12f2e9aa55e245664e86bfdf4eb000ddc316b48d9aa63c3c98ba886416868e49
ARG NPROC=1
ARG mrtrix3_version
ENV MRTRIX3_VERSION=$mrtrix3_version
WORKDIR /tmp
RUN curl -fsSLO https://raw.githubusercontent.com/cms-sw/cms-docker/master/slc6-vanilla/RPM-GPG-KEY-cern \
    && rpm --import RPM-GPG-KEY-cern \
    && curl -fsSL -o /etc/yum.repos.d/slc6-scl.repo http://linuxsoft.cern.ch/cern/scl/slc6-scl.repo \
    && yum install -y -q \
          curl \
          devtoolset-3-gcc-c++ \
          eigen3-devel \
          git \
          make \
          numpy \
          python \
          zlib-devel \
    && yum clean packages \
    && rm -rf /var/cache/yum/*
# Download and compile mrtrix3.
RUN if [ -z "$mrtrix3_version" ]; then \
        echo "ERROR: mrtrix3_version not defined" && exit 1; \
    fi \
    && git clone https://github.com/MRtrix3/mrtrix3.git \
    && cd mrtrix3 \
    && git checkout "$mrtrix3_version" \
    && source /opt/rh/devtoolset-3/enable \
    && ./configure -nogui \
    && echo "Compiling MRtrix3 ..." \
    && ./build
