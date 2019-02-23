#!/bin/bash

sudo yum update
sudo yum install -y yum-utils
sudo yum groupinstall development

sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
sudo yum install -y python36u
echo "checking for python installation"
python3.6 -V

sudo yum install -y python36u-pip
sudo yum install -y python36u-devel

python3.6 -m venv venv
. venv/bin/activate
<<<<<<< HEAD

sudo yum install -y sqlite3
=======
sudo yum install -y sqlite3

>>>>>>> be0afb23a612060f7f9521d96096c72e7be866b7
