FROM python:3.7
#FROM ubuntu:18.04
LABEL purpose="vc-base"
LABEL version="alpha-0.1"

ENV DIR_DOCKER=.
ENV DEBCONF_NOWARNINGS yes
ENV DEBIAN_FRONTEND=noninteractive

# Basic-layer
COPY ${DIR_DOCKER}/requirements.txt ./
ENV TZ="Asia/Tokyo"
RUN apt-get update -y -q
RUN apt-get install -y -q --no-install-recommends \
    tzdata
RUN apt-get install -y -q --no-install-recommends \
    wget \
    vim

# C++ layer
RUN apt-get install -y -q --no-install-recommends\
    build-essential \
    cmake \
    clang \
    libssl-dev

# Audio Layer
RUN apt-get install -y -q --no-install-recommends \
    pulseaudio

# Python Layer
RUN pip install -q --upgrade pip
RUN pip install -r requirements.txt -q

# finalize
WORKDIR /work
ENTRYPOINT ["/bin/bash"]