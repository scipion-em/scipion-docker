#!/bin/bash
set -xe

S_USER=scipionuser
S_USER_HOME=/home/${S_USER}

if [ -z "$ROOT_PASS" ] || [ -z "$USER_PASS" ] || [ -z "$USE_DISPLAY" ]; then
	echo "please run the container with these variables: \nROOT_PASS\nUSER_PASS\nUSE_DISPLAY\n"
	exit 1
fi

echo -e "$ROOT_PASS\n$ROOT_PASS" | passwd root
echo -e "$USER_PASS\n$USER_PASS" | passwd $S_USER

service ssh start

# Update cryosparc hostname and license
if ! [ -z $CRYOSPARC_LICENSE ] && [ -z $NOGPU ]; then
    sed -i -e "s+CRYOSPARC_MASTER_HOSTNAME=.*+CRYOSPARC_MASTER_HOSTNAME=\"$HOSTNAME\"+g" $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master/config.sh
    sed -i -e "s+CRYOSPARC_LICENSE_ID=.*+CRYOSPARC_LICENSE_ID=\"$CRYOSPARC_LICENSE\"+g" $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master/config.sh
    sudo -u $S_USER $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_master/bin/cryosparcm restart

    set +e
    # Connect worker
    sudo -u $S_USER $S_USER_HOME/cryosparc_${CRYOSPARC_VERSION}/cryosparc_worker/bin/cryosparcw connect --worker $HOSTNAME --master $HOSTNAME --nossd
fi

su - $S_USER -c /bin/bash