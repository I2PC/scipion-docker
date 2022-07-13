#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}

export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/TurboVNC/bin"

# Update cryosparc hostname and license
sed -i -e "s+CRYOSPARC_MASTER_HOSTNAME=.*+CRYOSPARC_MASTER_HOSTNAME=\"$HOSTNAME\"+g" $S_USER_HOME/cryosparc3/cryosparc_master/config.sh
sed -i -e "s+CRYOSPARC_LICENSE_ID=.*+CRYOSPARC_LICENSE_ID=\"$CRYOSPARC_LICENSE\"+g" $S_USER_HOME/cryosparc3/cryosparc_master/config.sh
sudo -u $S_USER $S_USER_HOME/cryosparc3/cryosparc_master/bin/cryosparcm restart

set +e
# Connect worker
sudo -u $S_USER $S_USER_HOME/cryosparc3/cryosparc_worker/bin/cryosparcw connect --worker $HOSTNAME --master $HOSTNAME --nossd

# Create dirs and simlinks
mkdir -p ${S_USER_HOME}/ScipionUserData/data
mkdir -p ${S_USER_HOME}/ScipionUserData/scipion_projects
ln -s ${S_USER_HOME}/ScipionUserData/scipion_projects ${S_USER_HOME}/cryosparc3/scipion_projects

# Update scipion (comment it out by now, not sure if it is good idea to update it anytime, better to have a controlled version)
#${S_USER_HOME}/scipion3/scipion3 update

set -e

echo $USE_DISPLAY
export WEBPORT=590${USE_DISPLAY}
export DISPLAY=:${USE_DISPLAY}

echo $WEBPORT
echo $DISPLAY

mkdir $S_USER_HOME/.vnc
echo $MYVNCPASSWORD
echo $MYVNCPASSWORD | vncpasswd -f > $S_USER_HOME/.vnc/passwd
chmod 0600 $S_USER_HOME/.vnc/passwd
/opt/websockify/run ${WEBPORT} --cert=/self.pem --ssl-only --web=/opt/noVNC --wrap-mode=ignore -- vncserver ${DISPLAY} -xstartup /tmp/xsession