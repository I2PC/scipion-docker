#!/bin/bash

set -ex

S_USER=scipionuser
S_USER_HOME=/home/$S_USER
CRYOS_LICENSE_ID=a3dc0cc0-3181-11ea-84d0-8b3771c7f13b

export USER=$S_USER
cd $S_USER_HOME/cryosparc3/cryosparc_master
./install.sh --standalone --license $CRYOS_LICENSE_ID --worker_path $S_USER_HOME/cryosparc3/cryosparc_worker --cudapath /usr/local/cuda --nossd --initial_email 'i2pc@cnb.csic.es' --initial_password 'i2pc' --initial_username 'i2pc' --initial_firstname 'cnb' --initial_lastname 'csic' --yes
rm $S_USER_HOME/cryosparc3/*.gz
echo -e "CRYOSPARC_HOME = $S_USER_HOME/cryosparc3" >> $S_USER_HOME/scipion3/config/scipion.conf