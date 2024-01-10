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

# Install cryosparc
if ! [ -z $CRYOSPARC_LICENSE ];
then su - ${S_USER} -c "${S_USER_HOME}/install_cryosparc.sh $CRYOSPARC_LICENSE";
else echo "No cryosparc because no gpu in the server"; fi

echo $USE_DISPLAY
export WEBPORT=590${USE_DISPLAY}
export DISPLAY=:${USE_DISPLAY}

echo $WEBPORT
echo $DISPLAY

su - ${S_USER} -c "mkdir $S_USER_HOME/.vnc"
echo $MYVNCPASSWORD
su - ${S_USER} -c "echo $MYVNCPASSWORD | /opt/TurboVNC/bin/vncpasswd -f > $S_USER_HOME/.vnc/passwd"
chmod 0600 $S_USER_HOME/.vnc/passwd
su - ${S_USER} -c "/opt/TurboVNC/bin/vncserver -novnc /usr/share/novnc -xstartup /tmp/xsession -x509cert /opt/TurboVNC/self.crt -x509key /opt/TurboVNC/self.key"
sleep 10000