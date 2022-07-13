#!/bin/bash

set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}

# Update scipion (comment it out by now, not sure if it is good idea to update it anytime, better to have a controlled version)
#${S_USER_HOME}/scipion3/scipion3 update