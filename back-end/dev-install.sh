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
