#!/bin/bash

CRYOS_LICENSE_ID=a3dc0cc0-3181-11ea-84d0-8b3771c7f13b

mkdir ${S_USER_HOME}/cryosparc3

cd ${S_USER_HOME}/cryosparc3 && \
    curl -L https://get.cryosparc.com/download/master-latest/$CRYOS_LICENSE_ID -o cryosparc_master.tar.gz && \
    tar -xf cryosparc_master.tar.gz
curl -L https://get.cryosparc.com/download/worker-latest/$CRYOS_LICENSE_ID -o cryosparc_worker.tar.gz && \
    tar -xf cryosparc_worker.tar.gz
cd $S_USER_HOME/cryosparc3/cryosparc_master && \
    ./install.sh --standalone --license $CRYOS_LICENSE_ID --worker_path $S_USER_HOME/cryosparc3/cryosparc_worker --cudapath /usr/local/cuda --nossd --initial_email 'i2pc@cnb.csic.es' --initial_password $MYVNCPASSWORD --initial_username 'i2pc' --initial_firstname 'cnb' --initial_lastname 'csic' --yes
rm $S_USER_HOME/cryosparc3/*.gz