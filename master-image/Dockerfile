
FROM rinchen.cnb.csic.es/eosc-synergy/scipion-worker:devel

ARG TURBOVNC_VERSION=2.2.4
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

ARG SLURM_VERSION=20.11.9
ARG CRYOSPARC_VERSION=3.3.2

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG CRYOSPARC_LICENSE=a0e74f16-3181-11ea-84b9-d7e876129116

ARG NOGPU

USER root
#######################

# Update nvidia repo keys
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

RUN apt-get update && apt-get upgrade -y

# Install necessary packages - xfce4, term, editor
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	dbus-x11 \
	xfce4 \
	xauth \
	xterm \
	konsole \
	pluma \
	firefox \
# websockify requirements
	python-numpy \
# Install useful packages
	vim \
	mesa-utils \
	htop \
	iputils-ping \
# Slurm requirements
    libmunge2 \
    libpq5 \
    munge \
    libmunge-dev \
    bzip2 \
    && rm -rf /var/lib/apt/lists/* \
    openssh-server

RUN useradd --uid 1052 -M slurm

# Install TurboVNC, VirtualGL, noVNC
RUN cd /tmp && \
    curl -fsSL -O https://deac-fra.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://deac-fra.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

ENV PATH ${PATH}:/opt/TurboVNC/bin

RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt && \
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC && \
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify && \
    ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html && \
    cd /opt/websockify && make

# Install Slurm client
RUN cd /tmp && \
    curl -fsSL -o slurm.tar.bz2 http://ftpgrycap.i3m.upv.es/src/slurm-${SLURM_VERSION}.tar.bz2 && \
    tar -xjf slurm.tar.bz2 -C /usr/local/ && \
    cd /usr/local/slurm-${SLURM_VERSION} && \
    ./configure && \
    make && \
    make install

# Create Scipion icon
RUN mkdir ${S_USER_HOME}/Desktop || true
COPY res/scipion_logo.png ${S_USER_HOME}/scipion3/
COPY res/Scipion.desktop ${S_USER_HOME}/Desktop/
RUN chmod +x ${S_USER_HOME}/scipion3/scipion_logo.png && \
    chmod +x ${S_USER_HOME}/Desktop/Scipion.desktop

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/Desktop

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,display

# Create TurboVNC config
RUN echo 'no-remote-connections\n\
no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
permitted-security-types = TLSVnc, TLSOtp, TLSPlain, TLSNone, X509Vnc, X509Otp, X509Plain, X509None, VNC, OTP, UnixLogin, Plain\
' > /etc/turbovncserver-security.conf

COPY res/turbovncserver.conf /etc/turbovncserver.conf

# Prepare environment
RUN mkdir /tmp/.X11-unix || true
RUN chmod -R ugo+rwx /tmp/.X11-unix

COPY xfce4 ${S_USER_HOME}/.config/xfce4/
RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/.config/xfce4

RUN echo '#!/bin/sh\n\
xfce4-session \
' >/tmp/xsession; chmod +x /tmp/xsession

ENV MYVNCPASSWORD Scipion4U
ENV EDITOR=/usr/bin/pluma

COPY self.pem /

USER ${S_USER}

COPY hosts.conf ${S_USER_HOME}/scipion3/config/

# Install cryosparc
COPY install_cryosparc_master.sh ${S_USER_HOME}/

RUN if [ -z $NOGPU ]; then ${S_USER_HOME}/install_cryosparc_master.sh; else echo "No cryosparc because no gpu in the server"; fi

# Install cryosparc plugin
RUN ${S_USER_HOME}/scipion3/scipion3 python -m pip install pyem
RUN ${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-cryosparc2

USER root

COPY docker-entrypoint-root.sh /
RUN chmod +x /docker-entrypoint-root.sh
COPY docker-entrypoint.sh ${S_USER_HOME}/
RUN chmod +x ${S_USER_HOME}/docker-entrypoint.sh

ENTRYPOINT [ "sh", "-c", "/docker-entrypoint-root.sh"]

