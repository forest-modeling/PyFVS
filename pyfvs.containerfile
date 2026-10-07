FROM ghcr.io/prefix-dev/pixi:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    #build-essential \
    git \
    gcc \
    g++ \
    gfortran \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

WORKDIR /
RUN git clone --recurse-submodules -b dev https://github.com/forest-modeling/PyFVS.git

WORKDIR /PyFVS

# Use the system cache for .pixi instead of the project folder
#   to avoid conflicts with local mounted projects during development
RUN mkdir -p /etc/pixi && \
    echo "detached-environments = true" >> /etc/pixi/config.toml

RUN pixi install --environment default
