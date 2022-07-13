FROM nvidia/cudagl:10.2-devel-ubuntu18.04

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG XMIPP_VERSION=xmippSrc-v3.22.04.0

LABEL LICENSE_RELION="https://raw.githubusercontent.com/3dem/relion/master/LICENSE" \
      LICENSE_CISTEM="http://license.janelia.org/license/janelia_license_1_2.html" \
#      LICENSE_MOTIONCORR2="https://docs.google.com/forms/d/e/1FAIpQLSfAQm5MA81qTx90W9JL6ClzSrM77tytsvyyHh1ZZWrFByhmfQ/viewform" \
      LICENSE_FSC3D="https://3dfsc.salk.edu/upload/info/"


# Update nvidia repo keys
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

RUN apt-get update && apt-get upgrade -y

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	tzdata \
	bash \
	make \
	curl \
	wget \
	openssh-client \
	ca-certificates \
	python3 \
	bison \
	flex \
	git \
	sudo \
    wget \
    gcc \
    g++ \
# Required by Scipion
	libxv1 \
	openjdk-8-jdk \
	libfftw3-dev \
	libtiff-dev \
    libopenmpi-dev \
    openmpi-bin \
    mesa-utils \
    openssh-client \
    cmake \
    libnss3 \
    libfontconfig1 \
    libxrender1 \
    libxtst6 \
    xterm \
    libasound2 \
    libglu1 \
    libxcursor1 \
    libdbus-1-3 \
    libxkbcommon-x11-0 \
    libhdf5-dev \
# Required by relion 4
    libxft-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Create scipionuser
RUN groupadd --gid 1042 ${S_USER} && \
    useradd --uid 1042 --create-home --home-dir ${S_USER_HOME} -s /bin/bash -g ${S_USER} ${S_USER} && \
    usermod -aG sudo ${S_USER}

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}

ENV CUDA_HOME "/usr/local/cuda"
ENV CUDA_BIN "/usr/local/cuda/bin"

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


USER ${S_USER}
#######################

RUN ["/bin/bash", "-c", "echo $CUDA_HOME"]
RUN ["/bin/bash", "-c", "echo $PATH"]


# Install Scipion
RUN wget --progress=dot:giga https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${S_USER_HOME}/miniconda.sh
RUN bash ${S_USER_HOME}/miniconda.sh -b
RUN ${S_USER_HOME}/miniconda3/bin/conda init
RUN ["/bin/bash", "-ci" , "python3 -m pip install scipion-installer"]
RUN ["/bin/bash", "-ci" , "cd ${S_USER_HOME} && python3 -m scipioninstaller ${S_USER_HOME}/scipion3 -noAsk -noXmipp -j $(nproc)"]

# Install xmipp without native compilation flags
RUN ["/bin/bash", "-c" , "${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-xmipp -j $(nproc) --noBin"]
RUN wget --progress=dot:giga http://scipion.cnb.csic.es/downloads/scipion/software/em/${XMIPP_VERSION}.tgz -O ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz
RUN tar xfz ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz -C ${S_USER_HOME}/scipion3/software/em/
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp noAsk config"]
RUN sed -i 's/-mtune=native -march=native //g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
#RUN sed -i 's/CUDA=True/CUDA=False/g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp compile"]
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp install"]
RUN ln -s ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/build ${S_USER_HOME}/scipion3/software/em/xmipp

# data directory for mount NFS using docker volume
RUN mkdir ${S_USER_HOME}/ScipionUserData

# Disable conda auto activation
RUN ${S_USER_HOME}/miniconda3/bin/conda config --set auto_activate_base false

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done

# Install deeplearningtoolkit
RUN ${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit -j $(nproc)

# Set the correct binary versions (this has to be reviewd to make it cleaner)

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
#RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/scipion3/software/em/motioncor2-1.4.7/bin/MotionCor2_1.4.7_Cuda102_12-09-2021 >> ${S_USER_HOME}/scipion3/config/scipion.conf

# Fix conda fonts
RUN wget https://anaconda.org/scipion/tk/8.6.10/download/linux-64/tk-8.6.10-h14c3975_1005.tar.bz2 -O ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2
RUN ${S_USER_HOME}/scipion3/scipion3 run conda remove -y tk --force && ${S_USER_HOME}/scipion3/scipion3 run conda install -y ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2

# Remove unused files
RUN  rm ${S_USER_HOME}/scipion3/software/em/*gz
RUN rm ${S_USER_HOME}/miniconda.sh
RUN rm ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2

RUN ln -s ${S_USER_HOME}/ScipionUserData/data ${S_USER_HOME}/scipion3/data

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]