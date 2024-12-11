# phusion (ubuntu) vs ubuntu directly: https://phusion.github.io/baseimage-docker/
FROM phusion/baseimage:noble-1.0.0

ARG AIIDA_VERSION=2.6.3

# Install OS dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    sudo \
    # development tools
    git \
    openssh-client \
    rsync \
    graphviz \
    vim \
    # the gcc compiler needs to build some python packages e.g. psutil and pymatgen
    build-essential \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ubuntu

ENV HOME=/home/ubuntu
ENV MAMBA_ROOT_PREFIX=$HOME/micromamba
ENV PATH=$MAMBA_ROOT_PREFIX/bin:$PATH

RUN mkdir -p $MAMBA_ROOT_PREFIX && \
    curl -L https://micromamba.snakepit.net/api/micromamba/linux-64/latest | tar -xvj -C $MAMBA_ROOT_PREFIX && \
    micromamba shell init --shell bash --root-prefix=$MAMBA_ROOT_PREFIX && \
    echo 'micromamba activate aiida' >> $HOME/.bashrc

RUN micromamba create -n aiida python=3.10 -c conda-forge aiida-core==${AIIDA_VERSION} -y

RUN micromamba run -n aiida pip install aiida-core[atomic_tools,rest]

WORKDIR "${HOME}"

COPY start-aiida-apis.sh .

CMD ["micromamba", "run", "--name", "aiida", "bash", "./start-aiida-apis.sh"]



