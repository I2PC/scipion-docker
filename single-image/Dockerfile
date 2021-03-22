
#FROM registry.gitlab.ics.muni.cz:443/eosc-synergy/scipion-docker/base-image:dev
FROM ldelcano/scipion-base:slurm

ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}

USER root
#######################

# Install necessary packages - xfce4, term, editor
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
	dbus-x11 \
	xfce4 \
	xauth \
	xterm \
	konsole \
	pluma

# libjpeg-turbo requirements
RUN apt update && apt install -y --no-install-recommends \
	cmake \
	gcc

# websockify requirements
RUN apt update && apt install -y --no-install-recommends \
	python-numpy

# Install useful packages
RUN apt update && apt install -y --no-install-recommends \
	git \
	vim \
	sudo \
	mesa-utils \
	htop

# Clean apt
RUN rm -rf /var/lib/apt/lists/*

# Install TurboVNC, VirtualGL, noVNC
RUN cd /tmp && \
    curl -fsSL -O https://deac-fra.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://deac-fra.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb \
        -O https://deac-fra.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb \
        -O https://deac-fra.dl.sourceforge.net/project/virtualgl/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin

RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    cd /opt/websockify && make

# Create Scipion icon
RUN mkdir ${S_USER_HOME}/Desktop || true
ADD res/scipion_logo.png ${S_USER_HOME}/scipion3/
ADD res/Scipion.desktop ${S_USER_HOME}/Desktop/
RUN chmod +x ${S_USER_HOME}/scipion3/scipion_logo.png && \
    chmod +x ${S_USER_HOME}/Desktop/Scipion.desktop

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/Desktop

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,display


USER ${S_USER}
#######################

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); rm ${S_USER_HOME}/scipion3/software/em/*gz; done

USER root
#######################

# Create TurboVNC config
RUN echo 'no-remote-connections\n\
no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
permitted-security-types = TLSVnc, TLSOtp, TLSPlain, TLSNone, X509Vnc, X509Otp, X509Plain, X509None, VNC, OTP, UnixLogin, Plain\
' > /etc/turbovncserver-security.conf

ADD res/turbovncserver.conf /etc/turbovncserver.conf

# Prepare environment
RUN mkdir /tmp/.X11-unix || true
RUN chmod -R ugo+rwx /tmp/.X11-unix

COPY xfce4 ${S_USER_HOME}/.config/xfce4/
RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/.config/xfce4

RUN echo '#!/bin/sh\n\
xfce4-session \
' >/tmp/xsession; chmod +x /tmp/xsession

ENV MYVNCPASSWORD abc
ENV EDITOR=/usr/bin/pluma

COPY self.pem /

COPY plugin-list.txt ${S_USER_HOME}/

# run docker-entrypoint.sh
COPY docker-entrypoint-root.sh /
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint-root.sh && \
    chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint-root.sh"]

