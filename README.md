# Scipion-docker

This repo contains all pieces of code needed to deploy an scipion single node or a slurm cluster.

There are three layers in this architecture: docker images at the botton, host machines in the middle and cloud infrastructure on the top.

There are two docker images: scipion-master and scipion-worker. Scipion-master  can be used to deploy a single  container with Scipion and a number of preinstalled plugins accesible through noVNC while scipion-worker image can be used to run Scipion tests or protocols.

The ansible recipes can be used to configure both master and worker hosts to be able to run the containers.

Finally, TOSCA (topology) and RADL files allow to deploy virtual machines on a cloud infrastructure.

## Prepare and run Master node manually
If you only want to deploy your own Scipion environment as a virtual machine you can build the master-image docker file and run a container as explained here.  

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

**Nvidia runtime installation**

https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)

**Configuration**

You should now have the **nvidia** runtime installed, which is required to run this project.

You can now replace the default docker runtime **runc** by **nvidia** runtime.  
Backup and edit file "**/etc/docker/daemon.json**".
```json
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
```

https://github.com/NVIDIA/nvidia-docker/wiki/Advanced-topics#default-runtime

If you need **runc** as a default runtime for some purpose, do not change this runtime.
Note that you will now need to start the docker image with "**--runtime=nvidia**".

### Run the master container (or single node)

#### Build the image before running the container
```bash
cd master-image
docker build .
```
#### Run the container

```
docker run -d --name=scipionmaster --hostname=scipion-master --privileged -p 5904:5904 -p 2222:22 -e USE_DISPLAY="4" -e ROOT_PASS="1234" -e USER_PASS="1234" -e MYVNCPASSWORD="1234" -e CRYOSPARC_LICENSE="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 -v /home/scipionuser/ScipionUserData:/home/scipionuser/ScipionUserData scipion-master
```

Env var "**USE_DISPLAY**" will create new display (e.g. "**:4**").
Please note that you need new one for each instance. Therefore change the "**USE_DISPLAY**" value for each instance.

Only one-digit display number is now supported.

This is also related to the port. Change last digit of the ports "**-p 5904:5904**".

You should also specify the ROOT_PASSWORD, USER_PASSWORD and MYVNCPASSWORD for the docker container as well as a new cryosparc license (there is a default one set up for testing but might give problems if in use in another container).

It is up to you to mount a shared folder for ScipionUserData.

Port 2222 allows to ssh in the docker machine.

In addition, if you are using default docker runtime, you have to run the container with "**--runtime=nvidia**" parameter.

### Test the master container

Your instance should be available on the link: "**https://your-ip-address:5904?resize=remote**".

You should use the MYVNCPASSWORD to login.

To check that nvidia is working fine open terminal a try "**nvidia-smi**" and "**glxgears -info**" commands.
Both should print output containing information about your nVidia graphics card.

## Run a test on the worker container

#### Build the image before running the container
```bash
cd worker-image
docker build .
```

#### Run

```
docker run -d --name=scipionworker --hostname=scipion-wn-1 --privileged -v /home/scipionuser/ScipionUserData:/home/scipionuser/ScipionUserData -u scipionuser scipion-worker "/home/scipionuser/scipion3/scipion3 test gctf.tests.test_protocols_gctf.TestGctf"
```
You can map a folder on the host to the ScipionUserData folder in the container to verify the test or you could simple check the container's log.

This example is runing a Gctf test but you could of course run the test you want.

## Deploy Scipion using the Infrastructure Manager

The architecture developed in this repo can be used to deploy virtual infrastructures in the cloud using the [Infrastructure Manager](https://www.grycap.upv.es/im/index.php).  

There are two options: deploy in a public cloud such as AWS or deploy in EOSC compute resources. The latest requires an account that is enrolled in a Virtual Organization that is supported by some cloud site.  

The following instructions show how to deploy on EOSC. AWS deployment has not been integrated yet but if you wish to use it or test it write an issue and we will help you.

### 1. Go to [IM-dashboard](https://appsgrycap.i3m.upv.es:31443/im-dashboard/login) and log in with your account
### 2. Add appropiated credentials to deploy in some cloud site

Go to the credentials menu on the right-upper part of the page and add the sites where you want to deploy.

![IM - dashboard cloud credentials](docs/im-dashboard-cloud-credentials.png)

### 3. Click on the infrastructure wizard for Scipion and fill up the form 

In the **HW Data** you should specify values such as number of GPUS, CPUs and RAM for master and worker as well as number of workers in the cluster (0 for a single node). Also the size of the external disk to be attached where Scipion projects will be stored.

In the **ScipionData** tab you need to specify the VNC password and Cryosparc license.

In the **Cloud Provider Selection** tab select the site where you want to deploy the cluster as well as the **Image** (Ubuntu 18 - bionic).
  
### 3. Submit your infrastructure

You can check the log to see that everything worked well and once the status be **configured** you can click on the URL given in **Outputs** to access the service. In order to access the host server you need to download the ssh key from the **VM0** link.

[Here](https://scipion-em.github.io/docs/docs/developer/scipion-infrastructure-cloud-usage) you can find documentation on how to use the service.

## Licenses

These Dockerfiles install several external packages with different licenses. Use the following commands to find about them:

```
docker inspect -f='{{.Config.Labels}}' scipion-worker
```
```
docker inspect -f='{{.Config.Labels}}' scipion-master
```

 