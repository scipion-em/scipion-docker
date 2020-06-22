# docker build -t scipioncudagl .
# xhost +
# docker run --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix scipioncudagl

FROM nvidia/cudagl:10.1-devel-ubuntu18.04

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,display

RUN apt update && apt upgrade -y

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

RUN apt update && apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gcc \
        libc6-dev \
        libglu1 \
        libsm6 \
        libxv1 \
        make \
        python \
        python-numpy \
        iputils-ping \
        x11-xkb-utils \
        xauth \
        xfonts-base \
        xkb-data \
	xterm \
        libdbus-1-3 \
	libxcb-keysyms1 \
	pluma \
	sudo \
	bison \
	flex \
	ssh \
	g++ \
        libssl1.0.0 \
        gcc-5 \
        g++-5 \
cmake openjdk-8-jdk libxft-dev libssl-dev libxext-dev\
 libxml2-dev libquadmath0 libxslt1-dev libopenmpi-dev openmpi-bin\
 libxss-dev libgsl0-dev libx11-dev gfortran libfreetype6-dev scons libfftw3-dev libopencv-dev git\
 mesa-utils \
	htop \
	vim && \
	rm -rf /var/lib/apt/lists/*

# Download scipion bundle
RUN curl -fsSL -o /tmp/scipion_latest_linux64_Ubuntu.tgz http://scipion.i2pc.es/startdownload/?bundleId=4
RUN cd /tmp/ && tar -xzf scipion_latest_linux64_Ubuntu.tgz && mv /tmp/scipion /opt/

# Create scipionuser
RUN groupadd -r scipionuser && \
    useradd -r -m -d /home/scipionuser -s /bin/bash -g scipionuser scipionuser

RUN usermod -aG sudo scipionuser
RUN echo "abc\nabc" | passwd root
RUN echo "abc\nabc" | passwd scipionuser

# Prepare home and Scipion for scipionuser
RUN chown -R scipionuser:scipionuser /home/scipionuser && \
    chown -R scipionuser:scipionuser /opt/scipion

USER scipionuser

# Install scipion
RUN echo "" | /opt/scipion/scipion config

RUN sed -i 's/MPI_LIBDIR\s*=.*/MPI_LIBDIR = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/lib/' /opt/scipion/config/scipion.conf && \
    sed -i 's/MPI_INCLUDE\s*=.*/MPI_INCLUDE = \/usr\/lib\/x86_64-linux-gnu\/openmpi\/include/' /opt/scipion/config/scipion.conf && \
    sed -i 's/CUDA\s*=.*/CUDA = True/' /opt/scipion/config/scipion.conf && \
    sed -i 's/CUDA_LIB\s*=.*/CUDA_LIB = \/usr\/local\/cuda\/lib64/' /opt/scipion/config/scipion.conf && \
    sed -i 's/CUDA_BIN\s*=.*/CUDA_BIN = \/usr\/local\/cuda\/bin/' /opt/scipion/config/scipion.conf && \
    echo "RELION_CUDA_LIB = /usr/local/cuda/lib64" >>  /opt/scipion/config/scipion.conf && \
    echo "RELION_CUDA_BIN = /usr/local/cuda/bin" >>  /opt/scipion/config/scipion.conf && \
    echo "MOTIONCOR2_BIN = MotionCor2_1.3.0-Cuda101" >>  /opt/scipion/config/scipion.conf && \
    echo "GCTF = Gctf_v1.18_sm30-75_cu10.1" >>  /opt/scipion/config/scipion.conf && \
    echo "GAUTOMATCH = Gautomatch_v0.56_sm30-75_cu10.1" >>  /opt/scipion/config/scipion.conf && \
    sed -i 's/NVCC_INCLUDE\s*=.*/NVCC_INCLUDE = \/usr\/local\/cuda\/include/' /opt/scipion/config/scipion.conf
    
RUN /opt/scipion/scipion install -j5

# Install xmipp plugin
RUN /opt/scipion/scipion installp -p scipion-em-xmipp

# Install xmipp and compile sources
RUN /opt/scipion/scipion installb xmippBin_Debian

# Install chimera plugin
RUN /opt/scipion/scipion installp -p scipion-em-chimera

# Install relion plugin (and compile relion sources). THIS MIGHT CHANGE TO COMPILE RELION FOR THE ARQUITECTURE
RUN /opt/scipion/scipion installp -p scipion-em-relion

# Install gctf plugin
RUN /opt/scipion/scipion installp -p scipion-em-gctf

# Install gautomatch plugin
RUN /opt/scipion/scipion installp -p scipion-em-gautomatch

# Install motioncor2 plugin
RUN /opt/scipion/scipion installp -p scipion-em-motioncorr

# Install eman2 plugin
RUN /opt/scipion/scipion installp -p scipion-em-eman2

# Delete em packages tar files (to free some space)
RUN rm /opt/scipion/software/em/*.tgz




