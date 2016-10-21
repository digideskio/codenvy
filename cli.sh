#!/bin/bash
# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Tyler Jewell - Initial Implementation
#

cli_init() {
  GLOBAL_NAME_MAP=$(docker info | grep "Name:" | cut -d" " -f2)
  GLOBAL_HOST_ARCH=$(docker version --format {{.Client}} | cut -d" " -f5)
  GLOBAL_HOST_IP=$(docker run --net host --rm codenvy/che-ip:nightly)
  GLOBAL_UNAME=$(docker run --rm alpine sh -c "uname -r")
  GLOBAL_GET_DOCKER_HOST_IP=$(get_docker_host_ip)

  DEFAULT_CODENVY_VERSION="hackathon"
  DEFAULT_CODENVY_UTILITY_VERSION="nightly"
  DEFAULT_CODENVY_CLI_ACTION="help"
  DEFAULT_CODENVY_DEVELOPMENT_MODE="off"
  DEFAULT_CODENVY_DEVELOPMENT_REPO=$(get_mount_path $PWD)
  DEFAULT_CODENVY_HOST=$GLOBAL_HOST_IP
  DEFAULT_CODENVY_CONFIG=$(get_mount_path $PWD)/config
  DEFAULT_CODENVY_INSTANCE=$(get_mount_path $PWD)/instance

  CODENVY_VERSION=${CODENVY_VERSION:-${DEFAULT_CODENVY_VERSION}}
  CODENVY_UTILITY_VERSION=${CODENVY_UTILITY_VERSION:-${DEFAULT_CODENVY_UTILITY_VERSION}}
  CODENVY_CLI_ACTION=${CODENVY_CLI_ACTION:-${DEFAULT_CODENVY_CLI_ACTION}}
  CODENVY_DEVELOPMENT_MODE=${CODENVY_DEVELOPMENT_MODE:-${DEFAULT_CODENVY_DEVELOPMENT_MODE}}
  CODENVY_DEVELOPMENT_REPO=${CODENVY_DEVELOPMENT_REPO:-$(get_mount_path ${DEFAULT_CODENVY_DEVELOPMENT_REPO})}
  CODENVY_HOST=${CODENVY_HOST:-${DEFAULT_CODENVY_HOST}}
  CODENVY_MANIFEST_DIR=$(get_mount_path ~/."${CHE_MINI_PRODUCT_NAME}"/manifests)
  
  CODENVY_INSTANCE=${CODENVY_INSTANCE:-${DEFAULT_CODENVY_INSTANCE}}
  CODENVY_CONFIG=${CODENVY_CONFIG:-${DEFAULT_CODENVY_CONFIG}}

  CODENVY_CONFIG_MANIFESTS_FOLDER="$CODENVY_CONFIG/manifests"
  CODENVY_CONFIG_MODULES_FOLDER="$CODENVY_CONFIG//modules"

  CODENVY_VERSION_FILE="codenvy.ver"
  CODENVY_ENVIRONMENT_FILE="codenvy.env"
  CODENVY_COMPOSE_FILE="docker-compose.yml"

  # For some situations, Docker requires a path for volume mount which is posix-based.
  # In other cases, the same file needs to be in windows format
  if has_docker_for_windows_client; then
    REFERENCE_ENVIRONMENT_FILE=$(convert_posix_to_windows $(echo "${CODENVY_INSTANCE}/${CODENVY_ENVIRONMENT_FILE}"))
    REFERENCE_COMPOSE_FILE=$(convert_posix_to_windows $(echo "${CODENVY_INSTANCE}/${CODENVY_COMPOSE_FILE}"))
  else
    REFERENCE_ENVIRONMENT_FILE="${CODENVY_INSTANCE}/${CODENVY_ENVIRONMENT_FILE}"
    REFERENCE_COMPOSE_FILE="${CODENVY_INSTANCE}/${CODENVY_COMPOSE_FILE}"
  fi

  DOCKER_CONTAINER_NAME_PREFIX="codenvy_"

  # TODO: Change this to use the current folder or perhaps ~?
  if is_boot2docker && has_docker_for_windows_client; then
    if [[ "${CODENVY_INSTANCE,,}" != *"${USERPROFILE,,}"* ]]; then
      CODENVY_INSTANCE=$(get_mount_path "${USERPROFILE}/.${CHE_MINI_PRODUCT_NAME}/")
      warning "Boot2docker for Windows - CODENVY_INSTANCE set to $CODENVY_INSTANCE"
    fi
    if [[ "${CODENVY_CONFIG,,}" != *"${USERPROFILE,,}"* ]]; then
      CODENVY_CONFIG=$(get_mount_path "${USERPROFILE}/.${CHE_MINI_PRODUCT_NAME}/")
      warning "Boot2docker for Windows - CODENVY_CONFIG set to $CODENVY_CONFIG"
    fi
  fi

  USAGE="
Usage: ${CHE_MINI_PRODUCT_NAME} [COMMAND]
    version                            Installed version and upgrade paths
    init                               Initializes a directory with a ${CHE_MINI_PRODUCT_NAME} configuration 
    start                              Starts ${CHE_MINI_PRODUCT_NAME} server
    stop                               Stops ${CHE_MINI_PRODUCT_NAME} server
    restart [--force]                  Restart ${CHE_MINI_PRODUCT_NAME} server
    destroy [--force]                  Stops services, and deletes ${CHE_MINI_PRODUCT_NAME} instance data
    config                             Generates a ${CHE_MINI_PRODUCT_NAME} configuration from vars and templates
    download [--force]                 Pulls Docker images to install offline CODENVY_VERSION
    info [ --all                       Run all debugging tests
           --server                    Run ${CHE_MINI_PRODUCT_NAME} launcher and server debugging tests
           --networking                Test connectivity between ${CHE_MINI_PRODUCT_NAME} sub-systems
           --cli                       Print CLI (this program) debugging info
           --create [<url>]            Test creating a workspace and project in ${CHE_MINI_PRODUCT_NAME}
                    [<user>]
                    [<pass>] ]

Variables:
    CODENVY_VERSION                     Version to run
    CODENVY_CONFIG                      Where the Codenvy config, CLI and variables are located
    CODENVY_INSTANCE                    Where ${CHE_MINI_PRODUCT_NAME} data, database, logs, are saved
    CODENVY_PORT                        External port of ${CHE_MINI_PRODUCT_NAME} server
    CODENVY_PROPERTY_<>                 One time use properties passed to ${CHE_MINI_PRODUCT_NAME} - see docs
    CODENVY_CLI_VERSION                 Version of CLI to run
    CODENVY_UTILITY_VERSION             Version of ${CHE_MINI_PRODUCT_NAME} launcher, mount, dev, action to run
    CODENVY_DEVELOPMENT_MODE            If 'on', then has images mount host source folders instead of embedded files
    CODENVY_DEVELOPMENT_REPO            Location of host git repository that contains source code to be mounted
"
}

### Should we load profile before we parse the command line?

cli_parse () {
  debug $FUNCNAME
  if [ $# -eq 0 ]; then
    CHE_CLI_ACTION="help"
  else
    case $1 in
      version|init|config|start|stop|restart|destroy|config|download|update|info|help|-h|--help)
        CHE_CLI_ACTION=$1
      ;;
      *)
        # unknown option
        error "You passed an unknown command line option."
        return 1;
      ;;
    esac
  fi
}


cli_cli() {
  case ${CHE_CLI_ACTION} in
    download)
      shift 
      cmd_download "$@"
    ;;
    init)
      shift 
      cmd_init "$@"
    ;;
    config)
      shift 
      cmd_config "$@"
    ;;
    start)
      shift
      cmd_start "$@"
    ;;
    stop)
      shift
      cmd_stop "$@"
    ;;
    restart)
      shift 
      cmd_restart "$@"
    ;;
    destroy)
      shift 
      cmd_destroy "$@"
    ;;
    version)
      shift 
      cmd_version "$@"
    ;;
    update)
      shift
      cmd_update
    ;;
    info)
      shift
      cmd_info "$@"
    ;;
    help)
      usage
    ;;
  esac
}

get_mount_path() {
  debug $FUNCNAME
  FULL_PATH=$(get_full_path "${1}")
  POSIX_PATH=$(convert_windows_to_posix "${FULL_PATH}")
  CLEAN_PATH=$(get_clean_path "${POSIX_PATH}")
  echo $CLEAN_PATH
}

usage () {
  debug $FUNCNAME
  printf "%s" "${USAGE}"
}

get_full_path() {
  debug $FUNCNAME
  # create full directory path
  echo "$(cd "$(dirname "${1}")"; pwd)/$(basename "$1")"
}

convert_windows_to_posix() {
  debug $FUNCNAME
  echo "/"$(echo "$1" | sed 's/\\/\//g' | sed 's/://')
}

convert_posix_to_windows() {
  debug $FUNCNAME
  # Remove leading slash
  VALUE="${1:1}"

  # Get first character (drive letter)
  VALUE2="${VALUE:0:1}"

  # Replace / with \
  VALUE3=$(echo ${VALUE} | tr '/' '\\' | sed 's/\\/\\\\/g')

  # Replace c\ with c:\ for drive letter
  echo "$VALUE3" | sed "s/./$VALUE2:/1"
}

get_clean_path() {
  debug $FUNCNAME
  INPUT_PATH=$1
  # \some\path => /some/path
  OUTPUT_PATH=$(echo ${INPUT_PATH} | tr '\\' '/')
  # /somepath/ => /somepath
  OUTPUT_PATH=${OUTPUT_PATH%/}
  # /some//path => /some/path
  OUTPUT_PATH=$(echo ${OUTPUT_PATH} | tr -s '/')
  # "/some/path" => /some/path
  OUTPUT_PATH=${OUTPUT_PATH//\"}
  echo ${OUTPUT_PATH}
}

get_docker_host_ip() {
  debug $FUNCNAME
  case $(get_docker_install_type) in
   boot2docker)
     NETWORK_IF="eth1"
   ;;
   native)
     NETWORK_IF="docker0"
   ;;
   *)
     NETWORK_IF="eth0"
   ;;
  esac

  docker run --rm --net host \
            alpine sh -c \
            "ip a show ${NETWORK_IF}" | \
            grep 'inet ' | \
            cut -d/ -f1 | \
            awk '{ print $2}'
}

has_docker_for_windows_client(){
  debug $FUNCNAME
  if [ "${GLOBAL_HOST_ARCH}" = "windows" ]; then
    return 0
  else
    return 1
  fi
}

get_docker_install_type() {
  debug $FUNCNAME
  if is_boot2docker; then
    echo "boot2docker"
  elif is_docker_for_windows; then
    echo "docker4windows"
  elif is_docker_for_mac; then
    echo "docker4mac"
  else
    echo "native"
  fi
}

is_boot2docker() {
  debug $FUNCNAME
  if echo "$GLOBAL_UNAME" | grep -q "boot2docker"; then
    return 0
  else
    return 1
  fi
}

is_docker_for_windows() {
  debug $FUNCNAME
  if is_moby_vm && has_docker_for_windows_client; then
    return 0
  else
    return 1
  fi
}

is_docker_for_mac() {
  debug $FUNCNAME
  if is_moby_vm && ! has_docker_for_windows_client; then
    return 0
  else
    return 1
  fi
}

is_native() {
  debug $FUNCNAME
  if [ $(get_docker_install_type) = "native" ]; then
    return 0
  else
    return 1
  fi
}

is_moby_vm() {
  debug $FUNCNAME
  if echo "$GLOBAL_NAME_MAP" | grep -q "moby"; then
    return 0
  else
    return 1
  fi
}

has_docker_for_windows_client(){
  debug $FUNCNAME
  if [ "${GLOBAL_HOST_ARCH}" = "windows" ]; then
    return 0
  else
    return 1
  fi
}

docker_exec() {
  debug $FUNCNAME
  if has_docker_for_windows_client; then
    MSYS_NO_PATHCONV=1 docker.exe "$@"
  else
    "$(which docker)" "$@"
  fi
}

has_env_variables() {
  debug $FUNCNAME
  PROPERTIES=$(env | grep CODENVY_)

  if [ "$PROPERTIES" = "" ]; then
    return 1
  else
    return 0
  fi
}

update_image_if_not_found() {
  debug $FUNCNAME

  printf "${GREEN}INFO:${NC} (${CHE_MINI_PRODUCT_NAME} download): Checking for image '$1'..."
  CURRENT_IMAGE=$(docker images -q "$1")
  if [ "${CURRENT_IMAGE}" == "" ]; then
    printf "not found\n"
    update_image $1
  else
    printf "found\n"
  fi
}

update_image() {
  debug $FUNCNAME
  if [ "${1}" == "--force" ]; then
    shift
    info "download" "Removing image $1"
    docker rmi -f $1 > /dev/null
  fi

  info "download" "Pulling image $1"
  echo ""
  docker pull $1
  echo ""
}

has_che_properties() {
  debug $FUNCNAME
  PROPERTIES=$(env | grep CHE_PROPERTY_)

  if [ "$PROPERTIES" = "" ]; then
    return 1
  else
    return 0
  fi
}

generate_temporary_che_properties_file() {
  debug $FUNCNAME
  if has_che_properties; then
    test -d ~/."${CHE_MINI_PRODUCT_NAME}"/conf || mkdir -p ~/."${CHE_MINI_PRODUCT_NAME}"/conf
    touch ~/."${CHE_MINI_PRODUCT_NAME}"/conf/che.properties

    # Get list of properties
    PROPERTIES_ARRAY=($(env | grep CHE_PROPERTY_))
    for PROPERTY in "${PROPERTIES_ARRAY[@]}"
    do
      # CHE_PROPERTY_NAME=value ==> NAME=value
      PROPERTY_WITHOUT_PREFIX=${PROPERTY#CHE_PROPERTY_}

      # NAME=value ==> separate name / value into different variables
      PROPERTY_NAME=$(echo $PROPERTY_WITHOUT_PREFIX | cut -f1 -d=)
      PROPERTY_VALUE=$(echo $PROPERTY_WITHOUT_PREFIX | cut -f2 -d=)

      # Replace "_" in names to periods
      CONVERTED_PROPERTY_NAME=$(echo "$PROPERTY_NAME" | tr _ .)

      # Replace ".." in names to "_"
      SUPER_CONVERTED_PROPERTY_NAME="${CONVERTED_PROPERTY_NAME//../_}"

      echo "$SUPER_CONVERTED_PROPERTY_NAME=$PROPERTY_VALUE" >> ~/."${CHE_MINI_PRODUCT_NAME}"/conf/che.properties
    done
  fi
}

contains() {
  string="$1"
  substring="$2"
  if test "${string#*$substring}" != "$string"
  then
    return 0    # $substring is in $string
  else
    return 1    # $substring is not in $string
  fi
}

port_open(){
  netstat -an | grep 0.0.0.0:$1 >/dev/null
  NETSTAT_EXIT=$?

  if [ $NETSTAT_EXIT = 0 ]; then
    return 1
  else
    return 0
  fi
}

get_server_container_id() {
  docker inspect -f '{{.Id}}' ${1}
}

wait_until_container_is_running() {
  CONTAINER_START_TIMEOUT=${1}

  ELAPSED=0
  until container_is_running ${2} || [ ${ELAPSED} -eq "${CONTAINER_START_TIMEOUT}" ]; do
    sleep 1
    ELAPSED=$((ELAPSED+1))
  done
}

container_is_running() {
  if [ "$(docker ps -qa -f "status=running" -f "id=${1}" | wc -l)" -eq 0 ]; then
    return 1
  else
    return 0
  fi
}

wait_until_server_is_booted () {
  SERVER_BOOT_TIMEOUT=${1}

  ELAPSED=0
  until server_is_booted ${2} || [ ${ELAPSED} -eq "${SERVER_BOOT_TIMEOUT}" ]; do
    sleep 2
    # Total hack - having to restart haproxy for some reason on windows
    if has_docker_for_windows_client; then
      docker restart codenvy_haproxy_1 > /dev/null
    fi
    ELAPSED=$((ELAPSED+1))
  done
}

server_is_booted() {
  HTTP_STATUS_CODE=$(curl -I http://$CODENVY_HOST:80/api/ \
                     -s -o /dev/null --write-out "%{http_code}")
  if [ "${HTTP_STATUS_CODE}" = "200" ]; then
    return 0
  else
    return 1
  fi
}

check_if_booted() {
  CODENVY_SERVER_CONTAINER_NAME="codenvy_codenvy_1"
  CURRENT_CODENVY_SERVER_CONTAINER_ID=$(get_server_container_id $CODENVY_SERVER_CONTAINER_NAME)
  wait_until_container_is_running 10 ${CURRENT_CODENVY_SERVER_CONTAINER_ID}
  if ! container_is_running ${CURRENT_CODENVY_SERVER_CONTAINER_ID}; then
    error "(${CHE_MINI_PRODUCT_NAME} start): Timeout waiting for ${CHE_PRODUCT_NAME} container to start."
    return 1
  fi

  info "start" "Server logs at \"docker logs -f ${CODENVY_SERVER_CONTAINER_NAME}\""
  info "start" "Server booting..."
  wait_until_server_is_booted 60 ${CURRENT_CODENVY_SERVER_CONTAINER_ID}

  if server_is_booted ${CURRENT_CODENVY_SERVER_CONTAINER_ID}; then
    info "start" "Booted and reachable"
#    info "$({CHE_MINI_PRODUCT_NAME} start): Ver: $(get_server_version ${CURRENT_CHE_SERVER_CONTAINER_ID})"
    info "start" "Use: http://${CODENVY_HOST}"
    info "start" "API: http://${CODENVY_HOST}/swagger"
  else
    error "(${CHE_MINI_PRODUCT_NAME} start): Timeout waiting for server. Run \"docker logs ${CODENVY_SERVER_CONTAINER_NAME}\" to inspect the issue."
    return 1
  fi
}

#TODO - is_initialized will return as initialized with empty directories
is_initialized() {
  debug $FUNCNAME
  if [[ -d "${CODENVY_CONFIG_MANIFESTS_FOLDER}" ]] && \
     [[ -d "${CODENVY_CONFIG_MODULES_FOLDER}" ]] && \
     [[ -f "${REFERENCE_ENVIRONMENT_FILE}" ]] && \
     [[ -f "${CODENVY_INSTANCE}/${CODENVY_VERSION_FILE}" ]]; then
    return 0
  else
    return 1
  fi
}

has_version_registry() {
  if [ -d ~/."${CHE_MINI_PRODUCT_NAME}"/manifests/$1 ]; then
    return 0;
  else
    return 1;
  fi
}

get_version_registry() {
  info "cli" "Downloading version registry..."

  ### Remove these comments once in production
  #docker rmi -f codenvy/version #> /dev/null 2>&1
  #docker pull codenvy/version #> /dev/null 2>&1 || true
  docker_exec run -v "${CODENVY_MANIFEST_DIR}":/copy codenvy/version
}

list_versions(){
  # List all subdirectories and then print only the file name
  for version in "${CODENVY_MANIFEST_DIR}"/* ; do
    echo " ${version##*/}"
  done
}

version_error(){
  echo ""
  echo "We could not find version '$1'. Available versions:"
  list_versions
  echo ""
  echo "Set CODENVY_VERSION=<version> and rerun."
  echo ""
}

### Returns the list of Codenvy images for a particular version of Codenvy
### Sets the images as environment variables after loading from file
get_image_manifest() {
  info "cli" "Checking registry for version '$1' images"
  if ! has_version_registry $1; then
    version_error $1
    return 1;  
  fi

  IMAGE_LIST=$(cat "$CODENVY_MANIFEST_DIR"/$1/images)
  IFS=$'\n'
  for SINGLE_IMAGE in $IMAGE_LIST; do
    eval $SINGLE_IMAGE
  done
}

get_upgrade_manifest() {
  if ! has_version_registry $1; then
    version_error $1
    return 1;  
  fi

  #  4.7.2 -> 5.0.0-M2-SNAPSHOT  <insert-syntax>
  #  4.7.2 -> 4.7.3              <insert-syntax>
  while IFS='' read -r line || [[ -n "$line" ]]; do
    VER=$(echo $line | cut -d ' ' -f1)
    UPG=$(echo $line | cut -d ' ' -f2)
    printf "  "
    printf "%s" $VER
    for i in `seq 1 $((25-${#VER}))`; do printf " "; done    
    printf "%s" $UPG
    printf "\n"
  done < "$CODENVY_MANIFEST_DIR"/$1/upgrades
}

get_version_manifest() {
  if ! has_version_registry $1; then
    version_error $1
    return 1;  
  fi

  while IFS='' read -r line || [[ -n "$line" ]]; do
    VER=$(echo $line | cut -d ' ' -f1)
    CHA=$(echo $line | cut -d ' ' -f2)
    UPG=$(echo $line | cut -d ' ' -f3)
    printf "  "
    printf "%s" $VER
    for i in `seq 1 $((25-${#VER}))`; do printf " "; done    
    printf "%s" $CHA
    for i in `seq 1 $((18-${#CHA}))`; do printf " "; done    
    printf "%s" $UPG
    printf "\n"
  done < "$CODENVY_MANIFEST_DIR"/$1/versions
}

get_installed_version() {
  if ! is_initialized; then
    echo "<not-installed>"
  else
    cat "${CODENVY_INSTANCE}"/$CODENVY_VERSION_FILE
  fi
}

get_installed_installdate() {
  if ! is_initialized; then
    echo "<not-installed>"
  else
    cat "${CODENVY_INSTANCE}"/$CODENVY_VERSION_FILE
  fi
}

get_installed_commitid() {
  if ! is_initialized; then
    echo "<not-installed>"
  else
    cat "${CODENVY_INSTANCE}"/$CODENVY_VERSION_FILE
  fi
}

###########################################################################
### END HELPER FUNCTIONS
###
### START CLI COMMANDS
###########################################################################
cmd_download() {
  FORCE_UPDATE=${1:-"--no-force"}

  get_version_registry
  get_image_manifest $CODENVY_VERSION

  IFS=$'\n'
  for SINGLE_IMAGE in $IMAGE_LIST; do
    VALUE_IMAGE=$(echo $SINGLE_IMAGE | cut -d'=' -f2)
    if [ $FORCE_UPDATE == "--force" ]; then
      update_image $FORCE_UPDATE $VALUE_IMAGE
    else
      update_image_if_not_found $VALUE_IMAGE
    fi
  done
}

cmd_init() {
  FORCE_UPDATE=${1:-"--no-force"}
  if [ "${FORCE_UPDATE}" == "--no-force" ]; then
    # If codenvy.environment file exists, then fail
    if is_initialized; then
      info "(${CHE_MINI_PRODUCT_NAME} init): Already initialized. Aborting."
      return 1
    fi
  fi
  
  cmd_download
  
  if [ -z ${IMAGE_INIT+x} ]; then
    get_image_manifest $CODENVY_VERSION
  fi

  info "init" "Installing configuration"
  mkdir -p "${CODENVY_CONFIG}"
  mkdir -p "${CODENVY_INSTANCE}"

  if [ ! -w "${CODENVY_CONFIG}" ]; then
    error "You have specified a CODENVY_CONFIG folder that is not writable. Aborting."
    return 1;
  fi

  if [ ! -w "${CODENVY_INSTANCE}" ]; then
    error "You have specified a CODENVY_INSTANCE folder that is not writable. Aborting."
    return 1;
  fi

  if [ "${CODENVY_DEVELOPMENT_MODE}" = "on" ]; then
    # docker pull codenvy/bootstrap with current directory as volume mount.
    docker_exec run -v "${CODENVY_CONFIG}":/copy \
                    -v "${CODENVY_DEVELOPMENT_REPO}":/files \
                       $IMAGE_INIT #> /dev/null 2>&1
  else
    # docker pull codenvy/bootstrap with current directory as volume mount.
    docker_exec run -v "${CODENVY_CONFIG}":/copy $IMAGE_INIT #> /dev/null 2>&1
  fi

  # After initialization, add codenvy.env with self-discovery.
  touch "${REFERENCE_ENVIRONMENT_FILE}"
  echo "CODENVY_HOST=${CODENVY_HOST}" > "${REFERENCE_ENVIRONMENT_FILE}"
  echo "CODENVY_SWARM_NODES=${CODENVY_HOST}:23750" >> "${REFERENCE_ENVIRONMENT_FILE}"
  echo "CODENVY_ENVIRONMENT=development" >> "${REFERENCE_ENVIRONMENT_FILE}"
  echo "CODENVY_INSTANCE=${CODENVY_INSTANCE}" >> "${REFERENCE_ENVIRONMENT_FILE}"
  echo "CODENVY_CONFIG=${CODENVY_CONFIG}" >> "${REFERENCE_ENVIRONMENT_FILE}"
}

cmd_config() {
  if ! is_initialized; then
    cmd_init
  fi

#TODO - Update this to use installed version instead of environment variable
  if [ -z ${IMAGE_PUPPET+x} ]; then
    get_image_manifest $CODENVY_VERSION
  fi

  info "config" "Generating codenvy configuration..."
  # Generate codenvy configuration using puppet
  # Note - bug in docker requires relative path for env, not absolute 
  docker_exec run -it --rm \
                  --env-file="${REFERENCE_ENVIRONMENT_FILE}" \
                  -v "${CODENVY_INSTANCE}":/opt/codenvy:rw \
                  -v "${CODENVY_CONFIG_MANIFESTS_FOLDER}":/etc/puppet/manifests:ro \
                  -v "${CODENVY_CONFIG_MODULES_FOLDER}":/etc/puppet/modules:ro \
                      $IMAGE_PUPPET \
                          apply --modulepath \
                                /etc/puppet/modules/ \
                                /etc/puppet/manifests/codenvy.pp > /dev/null


  # Replace certain environment file lines with wind
  if has_docker_for_windows_client; then
    info "config" "Customizing docker-compose for Windows"
    CODENVY_ENVFILE_REGISTRY=$(convert_posix_to_windows $(echo \
                                   "${CODENVY_INSTANCE}/config/registry/registry.env"))
    CODENVY_ENVFILE_POSTGRES=$(convert_posix_to_windows $(echo \
                                   "${CODENVY_INSTANCE}/config/postgres/postgres.env"))
    CODENVY_ENVFILE_CODENVY=$(convert_posix_to_windows $(echo \
                                   "${CODENVY_INSTANCE}/config/codenvy/codenvy.env"))
    sed "s|^.*registry\.env.*$|\ \ \ \ \ \ \-\ \'${CODENVY_ENVFILE_REGISTRY}\'|" -i "${REFERENCE_COMPOSE_FILE}"
    sed "s|^.*postgres\.env.*$|\ \ \ \ \ \ \-\ \'${CODENVY_ENVFILE_POSTGRES}\'|" -i "${REFERENCE_COMPOSE_FILE}"
    sed "s|^.*codenvy\.env.*$|\ \ \ \ \ \ \-\ \'${CODENVY_ENVFILE_CODENVY}\'|" -i "${REFERENCE_COMPOSE_FILE}"
    sed "s|^.*postgresql\/data.*$|\ \ \ \ \ \ \-\ \'codenvy-postgresql-volume\:\/var\/lib\/postgresql\/data\:Z\'|" -i "${REFERENCE_COMPOSE_FILE}"

    echo '' >> "${REFERENCE_COMPOSE_FILE}"
    echo 'volumes:' >> "${REFERENCE_COMPOSE_FILE}"
    echo '  codenvy-postgresql-volume:' >> "${REFERENCE_COMPOSE_FILE}"
    echo '     external: true' >> "${REFERENCE_COMPOSE_FILE}"

    # On Windows, it is not possible to volume mount postgres data folder directly
    # This creates a named volume which will store postgres data in docker for win VM
    # TODO - in future, we can write synchronizer utility to copy data from win VM to host
    docker volume create --name=codenvy-postgresql-volume > /dev/null
  fi;
}

cmd_start() {
  debug $FUNCNAME
  
  if [ $# -gt 0 ]; then
    error "${CHE_MINI_PRODUCT_NAME} start: You passed unknown options. Aborting."
    return
  fi

  # Always regenerate puppet configuration from environment variable source, whether changed or not.
  # If the current directory is not configured with an .env file, it will initialize
  cmd_config

  # Begin tests of open ports that we require
  info "start" "Preflight checks"
  printf "         port 80:  $(port_open 80 && echo "${GREEN}[OK]${NC}" || echo "${RED}[ALREADY IN USE]${NC}") \n"
  printf "         port 443: $(port_open 443 && echo "${GREEN}[OK]${NC}" || echo "${RED}[ALREADY IN USE]${NC}") \n"
  if ! $(port_open 80) || ! $(port_open 443); then
    error "Ports required to run Codenvy are being used by another program. Aborting..."
    return 1;
  fi
  printf "\n"
  
  # Start Codenvy
  # Note bug in docker requires relative path, not absolute path to compose file
  info "start" "Starting containers..."
  docker-compose --file="${REFERENCE_COMPOSE_FILE}" -p=codenvy up -d > /dev/null 2>&1
  check_if_booted
}

cmd_stop() {
  debug $FUNCNAME

  if [ $# -gt 0 ]; then
    error "${CHE_MINI_PRODUCT_NAME} stop: You passed unknown options. Aborting."
    return
  fi

  info "stop" "Stopping containers..."
  docker-compose --file="${REFERENCE_COMPOSE_FILE}" -p=codenvy stop > /dev/null 2>&1 || true
  info "stop" "Removing containers"
  docker rm $(docker ps -aq --filter name=${DOCKER_CONTAINER_NAME_PREFIX}) > /dev/null 2>&1 || true 
}

cmd_restart() {
  debug $FUNCNAME

  FORCE_UPDATE=${1:-"--no-force"}
  if [ "${FORCE_UPDATE}" == "--force" ]; then
    info "restart" "Stopping and removing containers..."
    cmd_stop
    info "restart" "Initiating clean start"
    cmd_start
  else
    info "restart" "Restarting services..."
    docker-compose --file="${REFERENCE_COMPOSE_FILE}" -p=codenvy restart > /dev/null 2>&1
    check_if_booted
  fi
}

cmd_destroy() {
  debug $FUNCNAME

  info "destroy" "!!! Stopping services and !!! deleting data !!! this is unrecoverable !!!"
  FORCE_DESTROY=${1:-"--no-force"}

  if [ ! "${FORCE_DESTROY}" == "--force" ]; then
    echo ""
    read -p "      Are you sure? [N/y] " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      return;
    fi
    echo ""
  fi

  cmd_stop
  info "destroy" "Deleting instance"
  rm -rf "${CODENVY_INSTANCE}"
  if has_docker_for_windows_client; then
    docker volume rm codenvy-postgresql-volume > /dev/null 2>&1 || true
  fi
  info "destroy" "Deleting config"
  rm -rf "${CODENVY_CONFIG}"
}

cmd_info() {
  debug $FUNCNAME
  if [ $# -eq 0 ]; then
    TESTS="--server"
  else
    TESTS=$1
  fi

  case $TESTS in
    --all|-all)
      cli_debug
      run_connectivity_tests
    ;;
    --networking|-networking)
      run_connectivity_tests
    ;;
    --server|-server)
      cli_debug
    ;;
    *)
      error "Unknown info flag passed: $2. Exiting."
    ;;
  esac
}

cmd_version() {
  debug $FUNCNAME

  # 1. CODENVY_VERSION is set to: x
  # 2. CODENVY_INSTANCE's version is set to:
  # 3. CLI_VERSION is:
  # Check to see version for current environment variable
  printf "Codenvy:\n"
  printf "  Version:      %s\n" $(get_installed_version)
  printf "  Installed:    %s\n" $(get_installed_installdate)
  printf "  Git commit:   %s\n" $(get_installed_commitid)
  printf "  CLI version:  $CHE_CLI_VERSION\n"

  if is_initialized; then
    printf "\n"
    printf "Upgrade Options:\n"
    printf "  INSTALLED VERSION        UPRADEABLE TO\n"
    get_upgrade_manifest $(get_installed_version)
  fi

  printf "\n"
  printf "Available:\n"
  printf "  VERSION                  CHANNEL           UPGRADEABLE FROM\n"
  if is_initialized; then
    get_version_manifest $(get_installed_version)
  else
    get_version_manifest $CODENVY_VERSION
  fi
}

cli_debug() {
  debug $FUNCNAME
  info "---------------------------------------"
  info "-------------   CLI INFO   ------------"
  info "---------------------------------------"
  info ""
  info "---------  PLATFORM INFO  -------------"
  info "CLI DEFAULT PROFILE       = $(has_default_profile && echo $(get_default_profile) || echo "not set")"
  info "CHE_VERSION               = ${CHE_VERSION}"
  info "CHE_CLI_VERSION           = ${CHE_CLI_VERSION}"
  info "CHE_UTILITY_VERSION       = ${CHE_UTILITY_VERSION}"
  info "DOCKER_INSTALL_TYPE       = $(get_docker_install_type)"
  info "DOCKER_HOST_IP            = ${GLOBAL_GET_DOCKER_HOST_IP}"
  info "IS_NATIVE                 = $(is_native && echo "YES" || echo "NO")"
  info "IS_WINDOWS                = $(has_docker_for_windows_client && echo "YES" || echo "NO")"
  info "IS_DOCKER_FOR_WINDOWS     = $(is_docker_for_windows && echo "YES" || echo "NO")"
  info "IS_DOCKER_FOR_MAC         = $(is_docker_for_mac && echo "YES" || echo "NO")"
  info "IS_BOOT2DOCKER            = $(is_boot2docker && echo "YES" || echo "NO")"
  info "HAS_DOCKER_FOR_WINDOWS_IP = $(has_docker_for_windows_ip && echo "YES" || echo "NO")"
  info "IS_MOBY_VM                = $(is_moby_vm && echo "YES" || echo "NO")"
  info "HAS_CHE_ENV_VARIABLES     = $(has_che_env_variables && echo "YES" || echo "NO")"
  info "HAS_TEMP_CHE_PROPERTIES   = $(has_che_properties && echo "YES" || echo "NO")"
  info "IS_INTERACTIVE            = $(has_interactive && echo "YES" || echo "NO")"
  info "IS_PSEUDO_TTY             = $(has_pseudo_tty && echo "YES" || echo "NO")"
  info ""
}

run_connectivity_tests() {
  debug $FUNCNAME
  info ""
  info "---------------------------------------"
  info "--------   CONNECTIVITY TEST   --------"
  info "---------------------------------------"
  # Start a fake workspace agent
  docker_exec run -d -p 12345:80 --name fakeagent alpine httpd -f -p 80 -h /etc/ > /dev/null

  AGENT_INTERNAL_IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' fakeagent)
  AGENT_INTERNAL_PORT=80
  AGENT_EXTERNAL_IP=$CODENVY_HOST
  AGENT_EXTERNAL_PORT=12345


  ### TEST 1: Simulate browser ==> workspace agent HTTP connectivity
  HTTP_CODE=$(curl -I localhost:${AGENT_EXTERNAL_PORT}/alpine-release \
                          -s -o /dev/null --connect-timeout 5 \
                          --write-out "%{http_code}") || echo "28" > /dev/null

  if [ "${HTTP_CODE}" = "200" ]; then
      info "Browser    => Workspace Agent (localhost)   : Connection succeeded"
  else
      info "Browser    => Workspace Agent (localhost)   : Connection failed"
  fi

  ### TEST 1a: Simulate browser ==> workspace agent HTTP connectivity
  HTTP_CODE=$(curl -I ${AGENT_EXTERNAL_IP}:${AGENT_EXTERNAL_PORT}/alpine-release \
                          -s -o /dev/null --connect-timeout 5 \
                          --write-out "%{http_code}") || echo "28" > /dev/null

  if [ "${HTTP_CODE}" = "200" ]; then
      info "Browser    => Workspace Agent ($AGENT_EXTERNAL_IP): Connection succeeded"
  else
      info "Browser    => Workspace Agent ($AGENT_EXTERNAL_IP): Connection failed"
  fi

  ### TEST 2: Simulate Che server ==> workspace agent (external IP) connectivity
#  export HTTP_CODE=$(docker run --rm --name fakeserver \
#                                --entrypoint=curl \
#                                ${CHE_SERVER_IMAGE_NAME}:${CHE_VERSION} \
#                                  -I ${AGENT_EXTERNAL_IP}:${AGENT_EXTERNAL_PORT}/alpine-release \
#                                 -s -o /dev/null \
#                                  --write-out "%{http_code}")

#  if [ "${HTTP_CODE}" = "200" ]; then
#      info "Server     => Workspace Agent (External IP): Connection succeeded"
#  else
#      info "Server     => Workspace Agent (External IP): Connection failed"
#  fi

  ### TEST 3: Simulate Che server ==> workspace agent (internal IP) connectivity
#  export HTTP_CODE=$(docker run --rm --name fakeserver \
#                                --entrypoint=curl \
#                                ${CHE_SERVER_IMAGE_NAME}:${CHE_VERSION} \
#                                  -I ${AGENT_INTERNAL_IP}:${AGENT_INTERNAL_PORT}/alpine-release \
#                                  -s -o /dev/null \
#                                  --write-out "%{http_code}")

#  if [ "${HTTP_CODE}" = "200" ]; then
#      info "Server     => Workspace Agent (Internal IP): Connection succeeded"
#  else
#      info "Server     => Workspace Agent (Internal IP): Connection failed"
#  fi

  docker rm -f fakeagent > /dev/null
}