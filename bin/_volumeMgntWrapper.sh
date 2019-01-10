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

GlusterVolumeName ()
{

    user_name="$1"

    echo "gv_${user_name}"
}

NfsMountPointOfGlusterVolume ()
{

    user_name="$1"

    echo "/gluster/$( GlusterVolumeName ${user_name} )"
}

DockerVolumeName ()
{

    user_name="$1"

    echo "gv_${user_name}"
}


CreateDockerVolumesFromGlusterVolume ()
{

    user_name="$1"

    nfs_mount_point=$( NfsMountPointOfGlusterVolume "${user_name}" )
    docker_volume_name=$( DockerVolumeName "${user_name}" )

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

	    set -x
	    docker -H "${endpoint}" \
		volume create \
		--driver local \
		--opt type=nfs \
		--opt o=addr=localhost,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14,vers=4 \
		--opt device=:${nfs_mount_point} \
		${docker_volume_name}
	    set +x
	fi
    done
}


RemoveDockerVolumesForGlusterVolume ()
{

    user_name="$1"

    docker_volume_name=$( DockerVolumeName "${user_name}" )

    for endpoint in ${DOCKER_ENPOINT_LIST}
    do

	volumes=$(
	    docker -H "${endpoint}" \
		volume ls -q --filter "Name=${docker_volume_name}"
	)

	if [ -z "${volumes}" ]
	then
	    echo "Volume ${docker_volume_name} does not exist on endpoint ${endpoint}. Skipping".
	else

	    set -x
	    docker -H "${endpoint}" \
		volume rm "${docker_volume_name}"
	    set +x
	fi
    done
}


CreateGlusterVolume4User ()
{

    user_name="$1"

    gluster_volume_name=$( GlusterVolumeName ${user_name} )

    volume_info=$(
	gluster \
	    volume info "${gluster_volume_name}" 2>/dev/null
    )
    if [ -n "${volume_info}" ]
    then
	echo "Gluster volume ${gluster_volume_name} already exists. Skipping".
    else

	set -x 
	gluster \
	    volume create \
	    $( GlusterVolumeName ${user_name} ) \
	    replica 3 \
	    s-raph-ale:/data/glusterfs/hpcvol/brick1/volumes/${user_name} \
	    s-huaweig560:/data/glusterfs/hpcvol/brick1/volumes/${user_name} \
	    s-cocolink:/data/glusterfs/hpcvol/brick1/volumes/${user_name} 
	gluster \
	    volume start $( GlusterVolumeName ${user_name} )
	set +x
    fi
}



case "${COMMAND}" in

    "createDockerVolumes4User.sh" )
	CreateDockerVolumesFromGlusterVolume "${user}"
	;;

    "removeDockerVolumes4User.sh" )
	RemoveDockerVolumesForGlusterVolume "${user}"
	;;

    "createGlusterVolume4User.sh" )
	CreateGlusterVolume4User "${user}"
	;;

    * )
	NotImplemented
	;;

esac
