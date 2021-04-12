
#FROM registry.gitlab.ics.muni.cz:443/eosc-synergy/scipion-docker/base-image:dev
FROM ldelcano/scipion-base:video_laura

ARG TURBOVNC_VERSION=2.2.4
ARG VIRTUALGL_VERSION=2.5.2
ARG LIBJPEG_VERSION=1.5.2
ARG WEBSOCKIFY_VERSION=0.8.0
ARG NOVNC_VERSION=1.1.0

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}

USER ${S_USER}
#######################

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done
RUN  rm ${S_USER_HOME}/scipion3/software/em/*gz


USER root

# Install useful packages
RUN apt update && apt install -y --no-install-recommends \
	iputils-ping

# Install cryosparc
USER ${S_USER}
RUN mkdir ${S_USER_HOME}/cryosparc3
ENV CRYOS_LICENSE_ID a3dc0cc0-3181-11ea-84d0-8b3771c7f13b
RUN curl -L https://get.cryosparc.com/download/master-latest/$CRYOS_LICENSE_ID -o ${S_USER_HOME}/cryosparc3/cryosparc_master.tar.gz
RUN curl -L https://get.cryosparc.com/download/worker-latest/$CRYOS_LICENSE_ID -o ${S_USER_HOME}/cryosparc3/cryosparc_worker.tar.gz
RUN tar -xf ${S_USER_HOME}/cryosparc3/cryosparc_master.tar.gz -C ${S_USER_HOME}/cryosparc3
RUN tar -xf ${S_USER_HOME}/cryosparc3/cryosparc_worker.tar.gz -C ${S_USER_HOME}/cryosparc3
COPY install_cryosparc.sh ${S_USER_HOME}/
USER root
RUN chown ${S_USER}.${S_USER} ${S_USER_HOME}/install_cryosparc.sh
RUN chmod +x ${S_USER_HOME}/install_cryosparc.sh
USER ${S_USER}
RUN cd ${S_USER_HOME} && ${S_USER_HOME}/install_cryosparc.sh

# Install deeplearningtoolkit
RUN ${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit -j $(nproc)

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/software/em/motioncor2-1.4.0/bin/MotionCor2_1.4.0_Cuda102 >> ${S_USER_HOME}/scipion3/config/scipion.conf

USER root
#######################

# run docker-entrypoint.sh
COPY docker-entrypoint-root.sh /
RUN chmod +x /docker-entrypoint-root.sh

ENTRYPOINT ["/docker-entrypoint-root.sh"]

