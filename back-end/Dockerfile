FROM centos:centos7

WORKDIR /
ADD dev-install.sh .
RUN ./dev-install.sh --docker-build

WORKDIR /server
ADD server .
