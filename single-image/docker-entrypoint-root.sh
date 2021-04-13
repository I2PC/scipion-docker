#!/bin/bash
set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}

chown $S_USER:$S_USER $S_USER_HOME/scipion3/software/em

chown -R $S_USER:$S_USER $S_USER_HOME/.config
chown -R $S_USER:$S_USER $S_USER_HOME/ScipionUserData

# Update cryosparc hostnames
sed -i -e "s+CRYOSPARC_MASTER_HOSTNAME=.*+CRYOSPARC_MASTER_HOSTNAME=\"$HOSTNAME\"+g" $S_USER_HOME/cryosparc3/cryosparc_master/config.sh
sudo -u $S_USER $S_USER_HOME/cryosparc3/cryosparc_master/bin/cryosparcm start
cd $S_USER_HOME/cryosparc3/cryosparc_worker
sudo -u $S_USER ./bin/cryosparcw connect --master localhost --port 39000 --worker $HOSTNAME --nossd

sudo -H -u $S_USER "$@"

