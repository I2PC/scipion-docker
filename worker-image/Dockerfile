FROM nvidia/cudagl:11.3-devel-ubuntu20.04

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG XMIPP_VERSION=xmippSrc-v3.22.04.0

LABEL license.relion="https://raw.githubusercontent.com/3dem/relion/master/LICENSE" 
LABEL license.cistem="http://license.janelia.org/license/janelia_license_1_2.html" 
LABEL license.motioncorr2="https://docs.google.com/forms/d/e/1FAIpQLSfAQm5MA81qTx90W9JL6ClzSrM77tytsvyyHh1ZZWrFByhmfQ/viewform"
LABEL license.fsc3d="https://3dfsc.salk.edu/upload/info/"


# Update nvidia repo keys
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
apt-key adv --fecth-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub && \
apt-get update && \
apt-get upgrade -y && \
DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	tzdata=2022e-0ubuntu2 \
	bash=5.0-6ubuntu1.2 \
	make-dfsg=4.2.1-1.2 \
	cmake=3.16.3-1ubuntu1 \
	curl=7.68.0-1ubuntu2.13 \
	wget=1.20.3-1ubuntu2 \
	openssh=1:8.2p1-4ubuntu0.6 \
	ca-certificates=20211016~20.04.1 \
	python3=3.8.2-0ubuntu2 \
	bison=2:3.5.1+dfsg-1 \
	flex=2.6.4-6.2 \
	git=1:2.25.1-1ubuntu3.5 \
	sudo=1.8.31-1ubuntu1.2 \
	gcc-10=10.3.0-1ubuntu1~20.04 \
	g++-10=10.3.0-1ubuntu1~20.04 \
	openjdk-11-jdk=11.0.16+8-0ubuntu1~20.04\
	libfftw3-dev=3.3.8-2ubuntu1 \
	libtiff-dev=4.1.0+git191117-2ubuntu0.20.04.5 \
	libopenmpi-dev=4.0.3-0ubuntu1 \
	openmpi-bin=4.0.3-0ubuntu1 \
	mesa-utils=8.4.0-1build1 \
	libnss3=2:3.49.1-1ubuntu1.8 \
	libfontconfig1=2.13.1-2ubuntu3 \
	libxrender1=1:0.9.10-1 \
	libxtst6=2:1.2.3-1 \
	xterm=353-1ubuntu1.20.04.2 \
	libasound2=1.2.2-2.1 \
	libglu1-mesa=9.0.1-1build1\
	libxcursor1=1:1.2.0-2 \
	libdbus-1-3=1.12.16-2ubuntu2.2 \
	libxkbcommon-x11-0=0.10.0-1 \
	libhdf5-dev=1.10.4+repack-11ubuntu1 \
	libxft-dev=2.3.3-0ubuntu1 \
	libpng-dev=1.6.37-2 \
	libxv1=2:1.0.11-1 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* 

# Create scipionuser
RUN groupadd --gid 1042 ${S_USER} && \
    useradd --uid 1042 --create-home --home-dir ${S_USER_HOME} -s /bin/bash -g ${S_USER} ${S_USER} && \
    usermod -aG sudo ${S_USER} && \
    chown -R ${S_USER}:${S_USER} ${S_USER_HOME}

ENV CUDA_HOME "/usr/local/cuda"
ENV CUDA_BIN "/usr/local/cuda/bin"

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility


USER ${S_USER}
#######################

RUN ["/bin/bash", "-c", "echo $CUDA_HOME"]
RUN ["/bin/bash", "-c", "echo $PATH"]


# Install Scipion
RUN wget --progress=dot:giga https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${S_USER_HOME}/miniconda.sh \
&& bash ${S_USER_HOME}/miniconda.sh -b \
&& ${S_USER_HOME}/miniconda3/bin/conda init \
&& ["/bin/bash", "-ci" , "python3 -m pip install scipion-installer"] \
&& ["/bin/bash", "-ci" , "cd ${S_USER_HOME} && python3 -m scipioninstaller ${S_USER_HOME}/scipion3 -noAsk -noXmipp -j $(nproc)"]

# Install xmipp without native compilation flags
RUN ["/bin/bash", "-c" , "${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-xmipp -j $(nproc) --noBin"] 
RUN wget --progress=dot:giga http://scipion.cnb.csic.es/downloads/scipion/software/em/${XMIPP_VERSION}.tgz -O ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz \
&& tar xfz ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz -C ${S_USER_HOME}/scipion3/software/em/ \
&& ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp noAsk config"]
RUN sed -i 's/-mtune=native -march=native //g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
#RUN sed -i 's/CUDA=True/CUDA=False/g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp compile"]
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp install"]
RUN ln -s ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/build ${S_USER_HOME}/scipion3/software/em/xmipp

# data directory for mount NFS using docker volume
RUN mkdir ${S_USER_HOME}/ScipionUserData \

# Disable conda auto activation
&& ${S_USER_HOME}/miniconda3/bin/conda config --set auto_activate_base false

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done

# Install deeplearningtoolkit
RUN ${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit -j $(nproc)

# Set the correct binary versions (this has to be reviewd to make it cleaner)

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
#RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/scipion3/software/em/motioncor2-1.4.7/bin/MotionCor2_1.4.7_Cuda102_12-09-2021 >> ${S_USER_HOME}/scipion3/config/scipion.conf

# Fix conda fonts
RUN wget --progress=dot:giga https://anaconda.org/scipion/tk/8.6.10/download/linux-64/tk-8.6.10-h14c3975_1005.tar.bz2 -O ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2 \
&& ${S_USER_HOME}/scipion3/scipion3 run conda remove -y tk --force && ${S_USER_HOME}/scipion3/scipion3 run conda install -y ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2

# Remove unused files
RUN rm ${S_USER_HOME}/scipion3/software/em/*gz \
&& rm ${S_USER_HOME}/miniconda.sh \
&& rm ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2 \
&& ln -s ${S_USER_HOME}/ScipionUserData/data ${S_USER_HOME}/scipion3/data

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
