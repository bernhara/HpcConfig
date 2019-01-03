#! /bin/bash

COMMAND_PATH="$0"
COMMAND=$( basename "${COMMAND_PATH}" )

user="$1"

if [ -z "${user}" ]
then
    echo "Usage: ${COMMAND} <user name>" 1>&2
    exit 1
fi

NotImplemented ()
{
    echo "${COMMAND} not implemented" 1>&2
}

CreateDockerVolumeFromGlusterVolume ()
{

    user_name="$1"

    gluster_volume_name="gv_${user_name}"
    docker_volume_name="gv_${user_name}"

    docker volume create \
	--driver local \
	--opt type=nfs \
	--opt o=addr=localhost,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14 \
	--opt device=:/${gluster_volume_name} \
	${docker_volume_name}
}


case "${COMMAND}" in

    "createDockerVolume4User.sh" )
	CreateDockerVolumeFromGlusterVolume "${user}"
	;;

    "createGlusterVolume4User.sh" )
	NotImplemented
	;;

    * )
	NotImplemented
	;;

esac
