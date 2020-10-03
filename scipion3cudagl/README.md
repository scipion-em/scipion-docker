# scipion-docker
Docker file to build docker image with scipion installed using nvidia cards.

## Set up

### Install docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -a -G docker username
```

### Install nvidia-docker
```
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey |  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list |  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd
```
Note: If you use KDE login cannot be in more than onegroup simultaneously so you need to change to `docker group` before running newgrp docker.

### Build the image
```
docker build -t scipion3cudagl .
```

### Test that works
```
xhost +
docker run --runtime=nvidia -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix scipion3cudagl
```

Once in the container run `glxgears`


