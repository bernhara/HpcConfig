#! /bin/bash

COMMAND_PATH="$0"
COMMAND=$( basename "${COMMAND_PATH}" )

DOCKER_ENPOINT_LIST="
   s-raph-ale:2375
   s-huaweig560:2375
   s-cocolink:2375
"

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

CreateDockerVolumesFromGlusterVolume ()
{

    user_name="$1"

    gluster_volume_name="gv_${user_name}"
    docker_volume_name="gv_${user_name}"

    for endpoint in ${DOCKER_ENPOINT_LIST}
    do

	volumes=$(
	    docker -H "${endpoint}" \
		volume ls -q --filter "Name=${docker_volume_name}"
	)

	if [ -n "${volumes}" ]
	then
	    echo "Volume ${docker_volume_name} already exists on endpoint ${endpoint}. Skipping".
	else

	    docker -H "${endpoint}" \
		volume create \
		--driver local \
		--opt type=nfs \
		--opt o=addr=localhost,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14 \
		--opt device=:/${gluster_volume_name} \
		${docker_volume_name}
	fi
    done
}


case "${COMMAND}" in

    "createDockerVolumes4User.sh" )
	CreateDockerVolumesFromGlusterVolume "${user}"
	;;

    "createGlusterVolume4User.sh" )
	NotImplemented
	;;

    * )
	NotImplemented
	;;

esac
