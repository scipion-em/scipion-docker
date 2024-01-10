# Scipion-docker

This repo contains all pieces of code needed to deploy an scipion single node.

### Prerequisites (ubuntu packages)
* nvidia drivers
* docker with nVidia runtime
* X11 server running
* **xserver-xorg xdm xauth nvidia-container-toolkit nvidia-container-runtime nvidia-docker2**

### Host machine
#### Configure xdm
When running on headless machine (or a machine where nobody is playing FPS games all the time), 
make sure the X server accepts unauthenticated local connections even when a user session is not running. 
E.g., the /etc/X11/xdm/xdm-config file should contain:

    DisplayManager*authorize:       false

However, such settings can be dangerous if the machine is not dedicated for this purpose, check for possible side effects.

#### Configure xorg
<!-- https://virtualgl.org/Documentation/HeadlessNV -->

**1. Run `nvidia-xconfig --query-gpu-info` to obtain the bus ID of the GPU. Example:**

```bash
Number of GPUs: 1

GPU #0:
  Name      : GeForce RTX 2080 SUPER
  UUID      : GPU-4fcfbe08-eee6-df4b-59aa-4c867e089b2f
  PCI BusID : PCI:10:0:0

  Number of Display Devices: 0
```

**2. Create an appropriate xorg.conf file for headless operation:**

```bash
sudo nvidia-xconfig -a --allow-empty-initial-configuration --use-display-device=None \
--virtual=1920x1200 --busid {busid}
```
Replace `{busid}` with the bus ID you obtained in Step 1. Leave out `--use-display-device=None` if the GPU is headless, i.e. if it has no display outputs.

**3. If you are using version 440.xx or later of the nVidia proprietary driver, then edit /etc/X11/xorg.conf and add**

```
Option "HardDPMS" "false"
```
under the Device or Screen section.

### Installation of prerequisites

#### Docker with nVidia runtime

**Docker installation**

https://docs.docker.com/engine/install/ubuntu/

**Nvidia container toolkit installation**

Follow the instructions to install and configure the Nvidia container toolkit in the followind link.

https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

### Build the image before running the container
```bash
cd scipion3cudagl
docker build .
```
### Run the container

```
docker run -d --name=scipion --hostname=scipion --privileged -p 5801:5801 -p 2222:22 -e USE_DISPLAY="1" -e ROOT_PASS="xxxx" -e USER_PASS="xxxx" -e MYVNCPASSWORD="xxxx" -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 scipion3cudagl
```

To run it without GPUs

```
docker run -d --name=scipion --hostname=scipion --privileged -p 5801:5801 -p 2222:22 --gpus all -p 3000:3000 -e USE_DISPLAY="1" -e ROOT_PASS="xxxx" -e USER_PASS="xxxx" -e MYVNCPASSWORD="xxxx" -e CRYOSPARC_LICENSE="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 scipion3cudagl
```

To run it with GPUs (supply Cryosparc version if you want to install it)

Env var "**USE_DISPLAY**" will create new display (e.g. "**:1**").
Please note that you need new one for each instance. Therefore change the "**USE_DISPLAY**" value for each instance.

Only one-digit display number is now supported.

This is also related to the port. Change last digit of the ports "**-p 5801:5801**".

You should also specify the ROOT_PASSWORD, USER_PASSWORD and MYVNCPASSWORD for the docker container as well as a new cryosparc license (in case you want a different one than the one supllied at build time).

It is up to you to mount a shared folder for ScipionUserData passing "**-p localpath:/home/scipionuser/ScipionUserData**" .

Port 2222 allows to ssh in the docker machine.

In addition, if you are using default docker runtime, you have to run the container with "**--runtime=nvidia**" parameter.

### Test the container

Your instance should be available on the link: "**https://localhost:5801/vnc.html?host=scipion&port=5901&encrypt=1?resize=remote**".

You should use the MYVNCPASSWORD to login.

To check that nvidia is working fine open terminal a try "**nvidia-smi**" and "**glxgears -info**" commands.
Both should print output containing information about your nVidia graphics card.

## Licenses

These Dockerfiles install several external packages with different licenses. Use the following commands to find about them:

```
docker inspect -f='{{.Config.Labels}}' scipion3cudagl
```

