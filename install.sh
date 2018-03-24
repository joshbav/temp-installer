sudo yum update -y && sudo yum install -y tar xz unzip curl ipset bind-utils &&  sudo systemctl stop firewalld && sudo systemctl disable firewalld

#####Verify NTP is setup and synchronized (not necessary in AWS)
timedatectl 

#Disable SELinux
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

# Verify we boot to the GUI 
#Dont do this on the bootstrap node because of disney license server
systemctl set-default multi-user.target


####  TODO: You must set the LC_ALL and LANG environment variables to en_US.utf-8.
# use localectl to check

#### DOCKER
sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

sudo yum -y install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager  --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-edge
sudo yum-config-manager --enable docker-ce-test
yum remove -y docker-engine-selinux container-selinux
yum install -y --setopt=obsoletes=0 docker-ce-17.05.0.ce

#Configure systemd to run the Docker Daemon with OverlayFS
sudo mkdir -p /etc/systemd/system/docker.service.d && sudo tee /etc/systemd/system/docker.service.d/override.conf <<- EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd --storage-driver=overlay
EOF

sudo systemctl enable docker

# Required for docker
sudo groupadd nogroup && sudo groupadd docker

#### end DOCKER

# since we are accidentally using the workstation version of centos we need to turn off the virbr0 interface since it’s using port 53 and DC/OS must control port 53.
systemctl disable libvirtd.service

# done
echo
echo DONE. Please reboot then do a docker run hello-world   to test

