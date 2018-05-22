echo "This is Josh's quick install prerequsite script for DC/OS on CentOS 7"

sudo yum update -y 
sudo yum install -y epel-release
sudo yum install -y tar xz unzip curl ipset bind-utils autofs nano ftp jq wget expect net-tools traceroute iproute telnet unzip yum-utils device-mapper-persistent-data lvm2
#sudo pip3 install --upgrade pip
#sudo pip3 install virtualenv 

sudo systemctl stop firewalld 
sudo systemctl disable firewalld


##### Verify NTP is setup and synchronized (not necessary in AWS)
# Note we are not installing chronyd or ntpd, you need to do that
timedatectl 

#### Disable SELinux
sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config

####  TODO: You must set the LC_ALL and LANG environment variables to en_US.utf-8.
# use localectl to check

#### DOCKER

sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && sudo yum install -y docker-ce-17.06.2.ce-1.el7.centos

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
echo DONE. Please reboot then do a 'docker run hello-world' to test

