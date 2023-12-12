# docker build -t scipion3cudagl .
# xhost +
# docker run --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix scipion3cudagl

FROM nvidia/cudagl:11.4.2-devel-ubuntu20.04

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}
ARG XMIPP_VERSION=xmippSrc-v3.23.11.0

ARG TURBOVNC_VERSION=3.0.3
ARG LIBJPEG_VERSION=3.0.1

ARG SLURM_VERSION=20.11.9
ARG CRYOSPARC_VERSION=4.4.0

ARG S_USER=scipionuser
ARG S_USER_HOME=/home/${S_USER}

# If cryosparc license is not supplied NOGPU should be set to 1 in order not to install ir or it will fail
ARG CRYOSPARC_LICENSE
ARG NOGPU

LABEL LICENSE_CRYOSPARC="https://guide.cryosparc.com/licensing/non-commercial-license-agreement"
LABEL LICENSE_RELION="https://raw.githubusercontent.com/3dem/relion/master/LICENSE" \
      LICENSE_CISTEM="http://license.janelia.org/license/janelia_license_1_2.html" \
#      LICENSE_MOTIONCORR2="https://docs.google.com/forms/d/e/1FAIpQLSfAQm5MA81qTx90W9JL6ClzSrM77tytsvyyHh1ZZWrFByhmfQ/viewform" \
      LICENSE_FSC3D="https://3dfsc.salk.edu/upload/info/"


# Update nvidia repo keys
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub

RUN apt-get update && apt-get upgrade -y

# Install necessary packages
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
	tzdata \
	bash \
	make \
	curl \
	wget \
	openssh-client \
	openssh-server \
	ca-certificates \
	python3 \
	bison \
	flex \
	git \
	sudo \
    wget \
    gcc \
    g++ \
	dbus-x11 \
	xfce4 \
	xauth \
	xterm \
	konsole \
	pluma \
	firefox \
	vim \
	mesa-utils \
	htop \
	iputils-ping \
# Required by Scipion
	libxv1 \
	default-jdk \
	libfftw3-dev \
	libtiff-dev \
    libopenmpi-dev \
    openmpi-bin \
    mesa-utils \
    cmake \
    libnss3 \
    libfontconfig1 \
    libxrender1 \
    libxtst6 \
    xterm \
    libasound2 \
    libglu1 \
    libxcursor1 \
    libdbus-1-3 \
    libxkbcommon-x11-0 \
    libhdf5-dev \
# Required by relion 4
    libxft-dev \
    libpng-dev \
# Novnc
    novnc \
    python3-websockify \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*

# Create scipionuser
RUN groupadd --gid 1042 ${S_USER} && \
    useradd --uid 1042 --create-home --home-dir ${S_USER_HOME} -s /bin/bash -g ${S_USER} ${S_USER} && \
    usermod -aG sudo ${S_USER}

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}

ENV CUDA_HOME "/usr/local/cuda"
ENV CUDA_BIN "/usr/local/cuda/bin"

ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

USER ${S_USER}

RUN ["/bin/bash", "-c", "echo $CUDA_HOME"]
RUN ["/bin/bash", "-c", "echo $PATH"]

# Install Scipion
RUN wget --progress=dot:giga https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ${S_USER_HOME}/miniconda.sh
RUN bash ${S_USER_HOME}/miniconda.sh -b
RUN ${S_USER_HOME}/miniconda3/bin/conda init
RUN ["/bin/bash", "-ci" , "python3 -m pip install scipion-installer"]
RUN ["/bin/bash", "-ci" , "cd ${S_USER_HOME} && python3 -m scipioninstaller ${S_USER_HOME}/scipion3 -noAsk -noXmipp -j $(nproc)"]

# Install xmipp without native compilation flags
RUN ["/bin/bash", "-c" , "${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-xmipp -j $(nproc) --noBin"]
RUN wget --progress=dot:giga http://scipion.cnb.csic.es/downloads/scipion/software/em/${XMIPP_VERSION}.tgz -O ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz
RUN tar xfz ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}.tgz -C ${S_USER_HOME}/scipion3/software/em/
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp noAsk config"]
RUN sed -i 's/-mtune=native -march=native //g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
#RUN sed -i 's/CUDA=True/CUDA=False/g' ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp.conf
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp compile"]
RUN ["/bin/bash", "-c" , "cd ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION} && ${S_USER_HOME}/scipion3/scipion3 run ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/xmipp install"]
RUN ln -s ${S_USER_HOME}/scipion3/software/em/${XMIPP_VERSION}/build ${S_USER_HOME}/scipion3/software/em/xmipp

# Install pyem
RUN ${S_USER_HOME}/scipion3/scipion3 python -m pip install pyem

# data directory for mount NFS using docker volume
RUN mkdir -p ${S_USER_HOME}/ScipionUserData/data && mkdir ${S_USER_HOME}/ScipionUserData/scipion_projects && chown $S_USER:$S_USER $S_USER_HOME/ScipionUserData

# Disable conda auto activation
RUN ${S_USER_HOME}/miniconda3/bin/conda config --set auto_activate_base false

# Install plugins for Scipion
COPY plugin-list.txt ${S_USER_HOME}/
RUN for pl in $(cat ${S_USER_HOME}/plugin-list.txt); do ${S_USER_HOME}/scipion3/scipion3 installp -p $pl -j $(nproc); done

# Install deeplearningtoolkit
#RUN ${S_USER_HOME}/scipion3/scipion3 installb deepLearningToolkit -j $(nproc)

# Set the correct binary versions (this has to be reviewd to make it cleaner)

# Modify MOTIONCOR2_BIN variable to point to cuda10.2 binary
#RUN echo MOTIONCOR2_BIN=${S_USER_HOME}/scipion3/software/em/motioncor2-1.4.7/bin/MotionCor2_1.4.7_Cuda102_12-09-2021 >> ${S_USER_HOME}/scipion3/config/scipion.conf

# Fix conda fonts
RUN wget --progress=dot:giga http://scipion.cnb.csic.es/downloads/packages/tk-8.6.10-h14c3975_1005.tar.bz2  -O ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2
RUN ${S_USER_HOME}/scipion3/scipion3 run conda remove -y tk --force && ${S_USER_HOME}/scipion3/scipion3 run conda install -y ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2

# Remove unused files
RUN  rm ${S_USER_HOME}/scipion3/software/em/*gz
RUN rm ${S_USER_HOME}/miniconda.sh
RUN rm ${S_USER_HOME}/tk-8.6.10-h14c3975_1005.tar.bz2

RUN ln -s ${S_USER_HOME}/ScipionUserData/data ${S_USER_HOME}/scipion3/data

RUN echo 'export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/TurboVNC/bin:$PATH' >> ${S_USER_HOME}/.bashrc

# Copy install_cryosparc.sh script
COPY install_cryosparc.sh ${S_USER_HOME}/

RUN if ! [ -z $CRYOSPARC_LICENSE ] && [ -z $NOGPU ]; then ${S_USER_HOME}/install_cryosparc.sh $CRYOSPARC_VERSION $CRYOSPARC_LICENSE; else echo "No cryosparc because no gpu in the server"; fi

# Install cryosparc plugin
RUN ${S_USER_HOME}/scipion3/scipion3 python -m pip install pyem
RUN ${S_USER_HOME}/scipion3/scipion3 installp -p scipion-em-cryosparc2

USER root

# Install TurboVNC, noVNC
RUN cd /tmp && \
    curl -fsSL -O https://deac-fra.dl.sourceforge.net/project/turbovnc/${TURBOVNC_VERSION}/turbovnc_${TURBOVNC_VERSION}_amd64.deb \
        -O https://deac-fra.dl.sourceforge.net/project/libjpeg-turbo/${LIBJPEG_VERSION}/libjpeg-turbo-official_${LIBJPEG_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb && \
    sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver

RUN ln -s /lib/websockify/rebind.cpython-38-x86_64-linux-gnu.so /lib/websockify/rebind.so

# Create TurboVNC config
RUN echo 'no-remote-connections\n\
no-httpd\n\
no-x11-tcp-connections\n\
no-pam-sessions\n\
permitted-security-types = TLSVnc, TLSOtp, TLSPlain, TLSNone, X509Vnc, X509Otp, X509Plain, X509None, VNC, OTP, UnixLogin, Plain\
' > /etc/turbovncserver-security.conf

COPY res/turbovncserver.conf /etc/turbovncserver.conf

COPY self.* /opt/TurboVNC/

# Create Scipion icon
RUN mkdir ${S_USER_HOME}/Desktop || true
COPY res/scipion_logo.png ${S_USER_HOME}/scipion3/
COPY res/Scipion.desktop ${S_USER_HOME}/Desktop/
RUN chmod +x ${S_USER_HOME}/scipion3/scipion_logo.png && \
    chmod +x ${S_USER_HOME}/Desktop/Scipion.desktop

RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/Desktop
RUN chown ${S_USER}:${S_USER} ${S_USER_HOME}/scipion3/scipion_logo.png

COPY xfce4 ${S_USER_HOME}/.config/xfce4/
RUN chown -R ${S_USER}:${S_USER} ${S_USER_HOME}/.config/xfce4

# Prepare environment
RUN mkdir /tmp/.X11-unix || true
RUN chmod -R ugo+rwx /tmp/.X11-unix

RUN echo '#!/bin/sh\n\
xfce4-session \
' >/tmp/xsession; chmod +x /tmp/xsession

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

#ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
ENTRYPOINT [ "sh", "-c", "/docker-entrypoint.sh"]