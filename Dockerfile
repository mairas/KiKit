FROM ubuntu:20.04 AS base

LABEL maintainer="Jan \"yaqwsx\" Mrázek" \
      description="Container for running KiKit applications"

ENV DISPLAY=unix:0.0

RUN export DEBIAN_FRONTEND="noninteractive" && apt-get update && \
    apt-get install -y --no-install-recommends \
      kicad kicad-libraries zip inkscape make git libmagickwand-dev \
      python3 python3-pip python3-wheel python3-setuptools inkscape \
      libgraphicsmagick1-dev libmagickcore-dev openscad && \
      rm -rf /var/lib/apt/lists/*

# hack: manually install Python dependencies to speed up the build process
# for repetitive builds

RUN pip3 install Pcbdraw numpy shapely click markdown2 pybars3 solidpython

# create a new stage for building and installing KiKit
FROM base AS build

COPY . /src/kikit
WORKDIR /src/kikit
RUN python3 setup.py install

# the final stage only takes the installed packages from dist-packages 
# and ignores the src directories
FROM base
COPY --from=build \
    /usr/local/lib/python3.8/dist-packages \
    /usr/local/lib/python3.8/dist-packages
COPY --from=build \
    /usr/local/bin \
    /usr/local/bin

CMD ["bash"]
