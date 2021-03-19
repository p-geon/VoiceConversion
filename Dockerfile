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
RUN apt-get install -y -q --no-install-recommends \
    wget \
	tmux
# Audio Layer
#> pulseaudio: コネクション
#> alsa-utils: aplayに必要
RUN apt-get install -y -q --no-install-recommends \
    pulseaudio

# Python Layer
RUN pip install -q --upgrade pip
RUN apt-get install -y -q --no-install-recommends \
	portaudio19-dev
RUN pip install -r requirements.txt -q

# additional layers
RUN apt-get install -y -q --no-install-recommends \
	alsa-utils
#	socat \

# conf
#COPY ./config/.tmux.conf /root/.tmux.conf
#ENV USER_DOCKER=pigeolian
#RUN useradd -m ${USER_DOCKER}
#RUN gpasswd -a ${USER_DOCKER} sudo
#USER ${USER_DOCKER}

# finalize
#ARG EXPOSED_PORT
EXPOSE 3000
WORKDIR /work
CMD ["/bin/bash"]

## 60±5sec (mac)