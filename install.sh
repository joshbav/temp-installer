echo
echo "This is Josh's quick install prerequsite script for DC/OS on CentOS 7"
echo "Tested on Centos 7.3 and 7.4"
echo
sudo yum update -y 
sudo yum install -y epel-release

#### ADD COMMON LINUX PACKAGES
# Only a few of these are required by DC/OS, however I've found
# that many minimal images are lacking some common optional utilities, 
# so I've added them here. Our requirements doc lists what DC/OS needs. 
sudo yum install -y tar xz unzip ipset bind-utils which gawk curl gettext host iproute util-linux sed  autofs nano ftp jq wget expect net-tools traceroute yum-utils device-mapper-persistent-data lvm2 which

#### Not used, in case I want python for automation
#sudo pip3 install --upgrade pip
#sudo pip3 install virtualenv 

# Turn off firewalld
echo
echo Disabling firewalld
echo
sudo systemctl stop firewalld 
sudo systemctl disable firewalld

# Likely not in use on CenOS server, but adding it anyhow to be safe
echo
echo Disabling dnsmasq, which shouldn't be in use anyhow
echo
sudo systemctl stop dnsmasq 
sudo systemctl disable dnsmasq.service

##### TO DO: Verify NTP is setup and synchronized (not necessary in AWS)
# Note we are not installing chronyd or ntpd, you need to do that
timedatectl 

#### Disable SELinux
echo
echo Disabling SELinux
echo
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

####  TO DO: You must set the LC_ALL and LANG environment variables to en_US.utf-8 if it's not set to the default
# Can use localectl to check

#### DOCKER
# This is just a normal Docker install, not DC/OS specific
echo
echo Installing Docker
echo
sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 

# Reference https://docs.mesosphere.com/version-policy/ for supported docker versions  
sudo yum install -y docker-ce-17.06.2.ce-1.el7.centos

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

echo
echo
echo DONE. Please reboot then do a 'sudo docker run hello-world' to test
echo
