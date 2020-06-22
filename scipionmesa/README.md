# scipion-docker
Docker file to build docker image with scipion installed to use mesa library on intel graphic cards.

## Set up

### Install docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo usermod -a -G docker username
```

### Build the image
```
docker build -t scipionmesa .
```

### Test that works
```
xhost +
docker run -ti --rm -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --device=/dev/dri:/dev/dri scipionmesa
```

Once in the container run `glxgears`


