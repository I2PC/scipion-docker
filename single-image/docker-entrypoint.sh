#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}
CRYOS_LICENSE_ID=a3dc0cc0-3181-11ea-84d0-8b3771c7f13b

export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/VirtualGL/bin:/opt/TurboVNC/bin"

# Update cryosparc hostnames
sed -i -e 's+CRYOSPARC_MASTER_HOSTNAME=.*+CRYOSPARC_MASTER_HOSTNAME="$HOSTNAME"+g' $S_USER_HOME/cryosparc3/cryosparc_master/config.sh
$S_USER_HOME/cryosparc3/cryosparc_master/bin/cryosparcm start
cd $S_USER_HOME/cryosparc3/cryosparc_worker
./bin/cryosparcw connect --master localhost --port 39000 --worker $HOSTNAME --nossd

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