#!/bin/bash

set -ex

S_USER=scipionuser
S_USER_HOME=/home/$S_USER

export USER=$S_USER

CRYOSPARC_VERSION="$1"
CRYOSPARC_LICENSE="$2"

mkdir ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}
curl -L https://get.cryosparc.com/download/master-v${CRYOSPARC_VERSION}/${CRYOSPARC_LICENSE} -o ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master.tar.gz
curl -L https://get.cryosparc.com/download/worker-v${CRYOSPARC_VERSION}/$CRYOSPARC_LICENSE -o ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/cryosparc_worker.tar.gz
tar -xf ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master.tar.gz -C ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}
tar -xf ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/cryosparc_worker.tar.gz -C ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}
rm ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/cryosparc_*.tar.gz

cd $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master
./install.sh --standalone --license $CRYOSPARC_LICENSE --worker_path $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_worker --nossd --initial_email 'i2pc@cnb.csic.es' --initial_password 'i2pc' --initial_username 'i2pc' --initial_firstname 'cnb' --initial_lastname 'csic' --yes
echo -e "CRYOSPARC_HOME = $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}" >> $S_USER_HOME/scipion3/config/scipion.conf
echo -e "CRYOSPARC_USER = i2pc@cnb.csic.es" >> $S_USER_HOME/scipion3/config/scipion.conf

ln -s ${S_USER_HOME}/ScipionUserData/scipion_projects ${S_USER_HOME}/cryosparc_${CRYOSPARC_VERSION}/scipion_projects
