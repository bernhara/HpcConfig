#! /bin/bash

HERE=$( dirname "$0" )

: ${IMAGE_TAG:="s-hpc-registry.ow.integ.dns-orange.fr/s-hpc-jupyter-centos7-cuda10.1:latest"}

docker build -t "${IMAGE_TAG}" "${HERE}"
