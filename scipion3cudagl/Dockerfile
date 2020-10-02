# docker build -t scipion3cudagl .
# xhost +
# docker run --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix scipioncudagl

FROM nvidia/cudagl:10.1-devel-ubuntu18.04

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,display

RUN apt update && apt upgrade -y

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

RUN apt-get update
RUN apt-get -y install sudo wget gcc g++ libopenmpi-dev mesa-utils openssh-client cmake libnss3 libfontconfig1 libxrender1 libxtst6 xterm libasound2 libglu1 libxcursor1 libdbus-1-3 libxkbcommon-x11-0
 
# Create scipion user
RUN groupadd -r scipion && \
    useradd -r -m -d /home/scipion -s /bin/bash -g scipion scipion

RUN usermod -aG sudo scipion
RUN echo "abc\nabc" | passwd root
RUN echo "abc\nabc" | passwd scipion

# Prepare home and Scipion for scipion
RUN chown -R scipion:scipion /home/scipion 

USER scipion

# Install scipion
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/scipion/miniconda.sh
RUN bash /home/scipion/miniconda.sh -b
RUN /home/scipion/miniconda3/bin/conda init
RUN  ["/bin/bash", "-ci" , "python -m pip install scipion-installer"]
RUN ["/bin/bash", "-ci" , "python -m scipioninstaller /home/scipion/scipion3 -noAsk -j 4"]

# Install plugins
RUN ["/bin/bash", "-ci" , "/home/scipion/scipion3/scipion3 installp -p scipion-em-relion -p scipion-em-gctf -p scipion-em-eman2 -p scipion-em-gautomatch"]
