FROM python:3.7
#FROM ubuntu:18.04
LABEL purpose="vc-desktop"
LABEL version="alpha-0.2.1"

ENV DIR_DOCKER=.
ENV DEBCONF_NOWARNINGS yes
ENV DEBIAN_FRONTEND=noninteractive

# Basic-layer
COPY ${DIR_DOCKER}/requirements.txt ./
ENV TZ="Asia/Tokyo"
RUN apt-get update -y -q
RUN apt-get install -y -q --no-install-recommends tzdata
#
RUN apt-get install -y -q --no-install-recommends \
    wget \
	tmux

# Audio Layer
# > pulseaudio: コネクション
# > alsa-utils: aplayに必要
#ENV PULSE_SERVER=docker.for.mac.localhost
RUN apt-get install -y -q --no-install-recommends \
    pulseaudio \
	alsa-utils

# Python Layer
RUN pip install -q --upgrade pip
RUN apt-get install -y -q --no-install-recommends \
	portaudio19-dev
RUN pip install -r requirements.txt -q

# finalize
USER root
EXPOSE 3000
WORKDIR /work
CMD ["/bin/bash"]