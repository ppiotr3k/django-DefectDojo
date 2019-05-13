#!/bin/bash

source ${BASH_SOURCE%/*}/../common-functions.bash
source ${BASH_SOURCE%/*}/../common-vars.bash


function build_docker_shared {
    #TODO: building all images under the same 'builder' reference makes no
    #      sense, unless checking resulting builds are pretty similar at the
    #      end; also consider handling several 'builder' images for evolutivity
    for docker_image in ${DOCKER_IMAGES[@]}
    do
	local image_repo="${DOCKER_USER}/${IMAGE_PREFIX}-builder"
	local build_tag="travis-${TRAVIS_BUILD_NUMBER}"

	travis_fold start docker_build.${docker_image}
	echo_info "building 'Dockerfile.${docker_image}'..."
	docker build \
	       --target build \
	       --tag "${image_repo}:${build_tag}" \
	       --file "Dockerfile.${docker_image}" \
	       ${PWD}

	return_value=${?}
	travis_fold end docker_build.${docker_image}

	[ ${return_value} -ne 0 ] &&
	    error_and_exit "cannot build '${docker_image}' image."

	echo_success "building '${docker_image}' image done."
    done
    return 0
}


run_or_die build_docker_shared