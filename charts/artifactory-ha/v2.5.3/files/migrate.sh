#!/bin/bash

# Flags
FLAG_Y="y"
FLAG_N="n"
FLAGS_Y_N="$FLAG_Y $FLAG_N"
FLAG_NOT_APPLICABLE="_NA_"

CURRENT_VERSION=$1

WRAPPER_SCRIPT_TYPE_RPMDEB="RPMDEB"
WRAPPER_SCRIPT_TYPE_DOCKER_COMPOSE="DOCKERCOMPOSE"

SENSITIVE_KEY_VALUE="__sensitive_key_hidden___"

# Shared system keys
SYS_KEY_SHARED_JFROGURL="shared.jfrogUrl"
SYS_KEY_SHARED_SECURITY_JOINKEY="shared.security.joinKey"
SYS_KEY_SHARED_SECURITY_MASTERKEY="shared.security.masterKey"

SYS_KEY_SHARED_NODE_ID="shared.node.id"
SYS_KEY_SHARED_JAVAHOME="shared.javaHome"

SYS_KEY_SHARED_DATABASE_TYPE="shared.database.type"
SYS_KEY_SHARED_DATABASE_TYPE_VALUE_POSTGRES="postgresql"
SYS_KEY_SHARED_DATABASE_DRIVER="shared.database.driver"
SYS_KEY_SHARED_DATABASE_URL="shared.database.url"
SYS_KEY_SHARED_DATABASE_USERNAME="shared.database.username"
SYS_KEY_SHARED_DATABASE_PASSWORD="shared.database.password"

SYS_KEY_SHARED_ELASTICSEARCH_URL="shared.elasticsearch.url"
SYS_KEY_SHARED_ELASTICSEARCH_USERNAME="shared.elasticsearch.username"
SYS_KEY_SHARED_ELASTICSEARCH_PASSWORD="shared.elasticsearch.password"
SYS_KEY_SHARED_ELASTICSEARCH_CLUSTERSETUP="shared.elasticsearch.clusterSetup"
SYS_KEY_SHARED_ELASTICSEARCH_UNICASTFILE="shared.elasticsearch.unicastFile"
SYS_KEY_SHARED_ELASTICSEARCH_CLUSTERSETUP_VALUE="YES"

# Define this in product specific script. Should contain the path to unitcast file
# File used by insight server to write cluster active nodes info. This will be read by elasticsearch
#SYS_KEY_SHARED_ELASTICSEARCH_UNICASTFILE_VALUE=""

SYS_KEY_RABBITMQ_ACTIVE_NODE_NAME="shared.rabbitMq.active.node.name"
SYS_KEY_RABBITMQ_ACTIVE_NODE_IP="shared.rabbitMq.active.node.ip"

# Filenames
FILE_NAME_SYSTEM_YAML="system.yaml"
FILE_NAME_JOIN_KEY="join.key"
FILE_NAME_MASTER_KEY="master.key"
FILE_NAME_INSTALLER_YAML="installer.yaml"

# Global constants used in business logic
NODE_TYPE_STANDALONE="standalone"
NODE_TYPE_CLUSTER_NODE="node"
NODE_TYPE_DATABASE="database"

# External(isable) databases 
DATABASE_POSTGRES="POSTGRES"
DATABASE_ELASTICSEARCH="ELASTICSEARCH"
DATABASE_RABBITMQ="RABBITMQ"

POSTGRES_LABEL="PostgreSQL"
ELASTICSEARCH_LABEL="Elasticsearch"
RABBITMQ_LABEL="Rabbitmq"

ARTIFACTORY_LABEL="Artifactory"
JFMC_LABEL="Mission Control"
DISTRIBUTION_LABEL="Distribution"
XRAY_LABEL="Xray"

POSTGRES_CONTAINER="postgres"
ELASTICSEARCH_CONTAINER="elasticsearch"
RABBITMQ_CONTAINER="rabbitmq"
REDIS_CONTAINER="redis"

#Adding a small timeout before a read ensures it is positioned correctly in the screen
read_timeout=0.5

# Options related to data directory location
PROMPT_DATA_DIR_LOCATION="Installation Directory"
KEY_DATA_DIR_LOCATION="installer.data_dir"

SYS_KEY_SHARED_NODE_HAENABLED="shared.node.haEnabled"
PROMPT_ADD_TO_CLUSTER="Are you adding an additional node to an existing product cluster?"
KEY_ADD_TO_CLUSTER="installer.ha"
VALID_VALUES_ADD_TO_CLUSTER="$FLAGS_Y_N"

MESSAGE_POSTGRES_INSTALL="The installer can install a $POSTGRES_LABEL database, or you can connect to an existing compatible $POSTGRES_LABEL database\n(compatible databases: https://www.jfrog.com/confluence/display/JFROG/System+Requirements#SystemRequirements-RequirementsMatrix)"
PROMPT_POSTGRES_INSTALL="Do you want to install $POSTGRES_LABEL?"
KEY_POSTGRES_INSTALL="installer.install_postgresql"
VALID_VALUES_POSTGRES_INSTALL="$FLAGS_Y_N"

# Postgres connection details
RPM_DEB_POSTGRES_HOME_DEFAULT="/var/opt/jfrog/postgres"
RPM_DEB_MESSAGE_STANDALONE_POSTGRES_DATA="$POSTGRES_LABEL home will have data and its configuration"
RPM_DEB_PROMPT_STANDALONE_POSTGRES_DATA="Type desired $POSTGRES_LABEL home location"
RPM_DEB_KEY_STANDALONE_POSTGRES_DATA="installer.postgresql.home"

MESSAGE_DATABASE_URL="Provide the database connection details"
PROMPT_DATABASE_URL(){
    local databaseURlExample=
    case "$PRODUCT_NAME" in
            $ARTIFACTORY_LABEL)
                databaseURlExample="jdbc:postgresql://<IP_ADDRESS>:<PORT>/artifactory"
            ;;
            $JFMC_LABEL)
                databaseURlExample="postgresql://<IP_ADDRESS>:<PORT>/mission_control?sslmode=disable"
            ;;
            $DISTRIBUTION_LABEL)
                databaseURlExample="jdbc:postgresql://<IP_ADDRESS>:<PORT>/distribution?sslmode=disable"
            ;;
            $XRAY_LABEL)
                databaseURlExample="postgres://<IP_ADDRESS>:<PORT>/xraydb?sslmode=disable"
            ;;
        esac
    if [ -z "$databaseURlExample" ]; then
        echo -n "$POSTGRES_LABEL URL" # For consistency with username and password
        return
    fi
    echo -n "$POSTGRES_LABEL url. Example: [$databaseURlExample]"
}
REGEX_DATABASE_URL(){
    local databaseURlExample=
    case "$PRODUCT_NAME" in
            $ARTIFACTORY_LABEL)
                databaseURlExample="jdbc:postgresql://.*/artifactory.*"
            ;;
            $JFMC_LABEL)
                databaseURlExample="postgresql://.*/mission_control.*"
            ;;
            $DISTRIBUTION_LABEL)
                databaseURlExample="jdbc:postgresql://.*/distribution.*"
            ;;
            $XRAY_LABEL)
                databaseURlExample="postgres://.*/xraydb.*"
            ;;
        esac
    echo -n "^$databaseURlExample\$"
}
ERROR_MESSAGE_DATABASE_URL="Invalid $POSTGRES_LABEL URL"
KEY_DATABASE_URL="$SYS_KEY_SHARED_DATABASE_URL"
#NOTE: It is important to display the label. Since the message may be hidden if URL is known
PROMPT_DATABASE_USERNAME="$POSTGRES_LABEL username"
KEY_DATABASE_USERNAME="$SYS_KEY_SHARED_DATABASE_USERNAME"
#NOTE: It is important to display the label. Since the message may be hidden if URL is known
PROMPT_DATABASE_PASSWORD="$POSTGRES_LABEL password"
KEY_DATABASE_PASSWORD="$SYS_KEY_SHARED_DATABASE_PASSWORD"
IS_SENSITIVE_DATABASE_PASSWORD="$FLAG_Y"

MESSAGE_STANDALONE_ELASTICSEARCH_INSTALL="The installer can install a $ELASTICSEARCH_LABEL database or you can connect to an existing compatible $ELASTICSEARCH_LABEL database"
PROMPT_STANDALONE_ELASTICSEARCH_INSTALL="Do you want to install $ELASTICSEARCH_LABEL?"
KEY_STANDALONE_ELASTICSEARCH_INSTALL="installer.install_elasticsearch"
VALID_VALUES_STANDALONE_ELASTICSEARCH_INSTALL="$FLAGS_Y_N"

# Elasticsearch connection details
MESSAGE_ELASTICSEARCH_DETAILS="Provide the $ELASTICSEARCH_LABEL connection details"
PROMPT_ELASTICSEARCH_URL="$ELASTICSEARCH_LABEL URL"
KEY_ELASTICSEARCH_URL="$SYS_KEY_SHARED_ELASTICSEARCH_URL"

PROMPT_ELASTICSEARCH_USERNAME="$ELASTICSEARCH_LABEL username"
KEY_ELASTICSEARCH_USERNAME="$SYS_KEY_SHARED_ELASTICSEARCH_USERNAME"

PROMPT_ELASTICSEARCH_PASSWORD="$ELASTICSEARCH_LABEL password"
KEY_ELASTICSEARCH_PASSWORD="$SYS_KEY_SHARED_ELASTICSEARCH_PASSWORD"
IS_SENSITIVE_ELASTICSEARCH_PASSWORD="$FLAG_Y"

# Cluster related questions
MESSAGE_CLUSTER_MASTER_KEY="Provide the cluster's master key. It can be found in the data directory of the first node under /etc/security/master.key"
PROMPT_CLUSTER_MASTER_KEY="Master Key"
KEY_CLUSTER_MASTER_KEY="$SYS_KEY_SHARED_SECURITY_MASTERKEY"
IS_SENSITIVE_CLUSTER_MASTER_KEY="$FLAG_Y"

MESSAGE_JOIN_KEY="The Join key is the secret key used to establish trust between services in the JFrog Platform.\n(You can copy the Join Key from Admin > Security > Settings)"
PROMPT_JOIN_KEY="Join Key"
KEY_JOIN_KEY="$SYS_KEY_SHARED_SECURITY_JOINKEY"
IS_SENSITIVE_JOIN_KEY="$FLAG_Y"
REGEX_JOIN_KEY="^[a-zA-Z0-9]{16,}\$"
ERROR_MESSAGE_JOIN_KEY="Invalid Join Key"

# Rabbitmq related cluster information
MESSAGE_RABBITMQ_ACTIVE_NODE_NAME="Provide an active ${RABBITMQ_LABEL} node name. Run the command [ hostname -s ] on any of the existing nodes in the product cluster to get this"
PROMPT_RABBITMQ_ACTIVE_NODE_NAME="${RABBITMQ_LABEL} active node name"
KEY_RABBITMQ_ACTIVE_NODE_NAME="$SYS_KEY_RABBITMQ_ACTIVE_NODE_NAME"

# Rabbitmq related cluster information (necessary only for docker-compose)
PROMPT_RABBITMQ_ACTIVE_NODE_IP="${RABBITMQ_LABEL} active node ip"
KEY_RABBITMQ_ACTIVE_NODE_IP="$SYS_KEY_RABBITMQ_ACTIVE_NODE_IP"

MESSAGE_JFROGURL(){
    echo -e "The JFrog URL allows ${PRODUCT_NAME} to connect to a JFrog Platform Instance.\n(You can copy the JFrog URL from Admin > Security > Settings)"
}
PROMPT_JFROGURL="JFrog URL"
KEY_JFROGURL="$SYS_KEY_SHARED_JFROGURL"
REGEX_JFROGURL="^https?://.*:{0,}[0-9]{0,4}\$"
ERROR_MESSAGE_JFROGURL="Invalid JFrog URL"


# Set this to FLAG_Y on upgrade
IS_UPGRADE="${FLAG_N}"

# This belongs in JFMC but is the ONLY one that needs it so keeping it here for now. Can be made into a method and overridden if necessary
MESSAGE_MULTIPLE_PG_SCHEME="Please setup $POSTGRES_LABEL with schema as described in https://www.jfrog.com/confluence/display/JFROG/Installing+Mission+Control"

_getMethodOutputOrVariableValue() {
    unset EFFECTIVE_MESSAGE
    local keyToSearch=$1
    local effectiveMessage=
    local result="0"
    # logSilly "Searching for method: [$keyToSearch]"
    LC_ALL=C type "$keyToSearch" > /dev/null 2>&1 || result="$?"
    if [[ "$result" == "0" ]]; then
        # logSilly "Found method for [$keyToSearch]"
        EFFECTIVE_MESSAGE="$($keyToSearch)"
        return
    fi
    eval EFFECTIVE_MESSAGE=\${$keyToSearch}
    if [ ! -z "$EFFECTIVE_MESSAGE" ]; then
        return
    fi
    # logSilly "Didn't find method or variable for [$keyToSearch]"
}


# REF https://misc.flogisoft.com/bash/tip_colors_and_formatting
cClear="\e[0m"
cBlue="\e[38;5;69m"
cRedDull="\e[1;31m"
cYellow="\e[1;33m"
cRedBright="\e[38;5;197m"
cBold="\e[1m"


_loggerGetModeRaw() {
    local MODE="$1"
    case $MODE in
    INFO)
        printf ""
    ;;
    DEBUG)
        printf "%s" "[${MODE}] "
    ;;
    WARN)
        printf "${cRedDull}%s%s${cClear}" "[" "${MODE}" "] "
    ;;
    ERROR)
        printf "${cRedBright}%s%s${cClear}" "[" "${MODE}" "] "
    ;;
    esac
}


_loggerGetMode() {
    local MODE="$1"
    case $MODE in
    INFO)
        printf "${cBlue}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    DEBUG)
        printf "%-7s" "[${MODE}]"
    ;;
    WARN)
        printf "${cRedDull}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    ERROR)
        printf "${cRedBright}%s%-5s%s${cClear}" "[" "${MODE}" "]"
    ;;
    esac
}

# Capitalises the first letter of the message
_loggerGetMessage() {
    local originalMessage="$*"
    local firstChar=$(echo "${originalMessage:0:1}" | awk '{ print toupper($0) }')
    local resetOfMessage="${originalMessage:1}"
    echo "$firstChar$resetOfMessage"
}

# The spec also says content should be left-trimmed but this is not necessary in our case. We don't reach the limit.
_loggerGetStackTrace() {
    printf "%s%-30s%s" "[" "$1:$2" "]"
}

_loggerGetThread() {
    printf "%s" "[main]"
}

_loggerGetServiceType() {
    printf "%s%-5s%s" "[" "shell" "]"
}

#Trace ID is not applicable to scripts
_loggerGetTraceID() {
    printf "%s" "[]"
}

logRaw() {
    echo ""
    printf "$1"
    echo ""
}

logBold(){
    echo ""
    printf "${cBold}$1${cClear}"
    echo ""
}

# The date binary works differently based on whether it is GNU/BSD
is_date_supported=0
date --version > /dev/null 2>&1 || is_date_supported=1
IS_GNU=$(echo $is_date_supported)

_loggerGetTimestamp() {
    if [ "${IS_GNU}" == "0" ]; then
        echo -n $(date -u +%FT%T.%3NZ)
    else
        echo -n $(date -u +%FT%T.000Z)
    fi
}

# https://www.shellscript.sh/tips/spinner/
_spin()
{
    spinner="/|\\-/|\\-"
    while :
    do
    for i in `seq 0 7`
    do
        echo -n "${spinner:$i:1}"
        echo -en "\010"
        sleep 1
    done
    done
}

showSpinner() {
    # Start the Spinner:
    _spin &
    # Make a note of its Process ID (PID):
    SPIN_PID=$!
    # Kill the spinner on any signal, including our own exit.
    trap "kill -9 $SPIN_PID" `seq 0 15` &> /dev/null || return 0
}

stopSpinner() {
    local occurrences=$(ps -ef | grep -wc "${SPIN_PID}")
    let "occurrences+=0"
    # validate that it is present (2 since this search itself will show up in the results)
    if [ $occurrences -gt 1 ]; then
        kill -9 $SPIN_PID &>/dev/null || return 0
        wait $SPIN_ID &>/dev/null
    fi
}

_getEffectiveMessage(){
    local MESSAGE="$1"
    local MODE=${2-"INFO"}

    if [ -z "$CONTEXT" ]; then
        CONTEXT=$(caller)
    fi

    _EFFECTIVE_MESSAGE=
    if [ -z "$LOG_BEHAVIOR_ADD_META" ]; then
        _EFFECTIVE_MESSAGE="$(_loggerGetModeRaw $MODE)$(_loggerGetMessage $MESSAGE)"
    else
        local SERVICE_TYPE="script"
        local TRACE_ID=""
        local THREAD="main"
        
        local CONTEXT_LINE=$(echo "$CONTEXT" | awk '{print $1}')
        local CONTEXT_FILE=$(echo "$CONTEXT" | awk -F"/" '{print $NF}')
        
        _EFFECTIVE_MESSAGE="$(_loggerGetTimestamp) $(_loggerGetServiceType) $(_loggerGetMode $MODE) $(_loggerGetTraceID) $(_loggerGetStackTrace $CONTEXT_FILE $CONTEXT_LINE) $(_loggerGetThread) - $(_loggerGetMessage $MESSAGE)"
    fi
    CONTEXT=
}

# Important - don't call any log method from this method. Will become an infinite loop. Use echo to debug
_logToFile() {
    local MODE=${1-"INFO"}
    local targetFile="$LOG_BEHAVIOR_ADD_REDIRECTION"
    # IF the file isn't passed, abort
    if [ -z "$targetFile" ]; then
        return
    fi
    # IF this is not being run in verbose mode and mode is debug or lower, abort
    if [ "${VERBOSE_MODE}" != "$FLAG_Y" ] && [ "${VERBOSE_MODE}" != "true" ] && [ "${VERBOSE_MODE}" != "debug" ]; then
        if [ "$MODE" == "DEBUG" ] || [ "$MODE" == "SILLY" ]; then
            return
        fi
    fi

    # Create the file if it doesn't exist
    if [ ! -f "${targetFile}" ]; then
        return
        # touch $targetFile > /dev/null 2>&1 || true
    fi
    # # Make it readable
    # chmod 640 $targetFile > /dev/null 2>&1 || true

    # Log contents
    printf "%s\n" "$_EFFECTIVE_MESSAGE" >> "$targetFile" || true
}

logger() {
    if [ "$LOG_BEHAVIOR_ADD_NEW_LINE" == "$FLAG_Y" ]; then
        echo ""
    fi
    _getEffectiveMessage "$@"
    local MODE=${2-"INFO"}
    printf "%s\n" "$_EFFECTIVE_MESSAGE"
    _logToFile "$MODE"
}

logDebug(){
    VERBOSE_MODE=${VERBOSE_MODE-"false"}
    CONTEXT=$(caller)
    if [ "${VERBOSE_MODE}" == "$FLAG_Y" ] || [ "${VERBOSE_MODE}" == "true" ] || [ "${VERBOSE_MODE}" == "debug" ];then
        logger "$1" "DEBUG"
    else
        logger "$1" "DEBUG" >&6
    fi
    CONTEXT=
}

logSilly(){
    VERBOSE_MODE=${VERBOSE_MODE-"false"}
    CONTEXT=$(caller)
    if [ "${VERBOSE_MODE}" == "silly" ];then
        logger "$1" "DEBUG"
    else
        logger "$1" "DEBUG" >&6
    fi
    CONTEXT=
}

logError() {
    CONTEXT=$(caller)
    logger "$1" "ERROR"
    CONTEXT=
}

errorExit () {
    CONTEXT=$(caller)
    logger "$1" "ERROR"
    CONTEXT=
    exit 1
}

warn () {
    CONTEXT=$(caller)
    logger "$1" "WARN"
    CONTEXT=
}

note () {
    CONTEXT=$(caller)
    logger "$1" "NOTE"
    CONTEXT=
}

bannerStart() {
    title=$1
    echo
    echo -e "\033[1m${title}\033[0m"
    echo
}

bannerSection() {
    title=$1
    echo
    echo -e "******************************** ${title} ********************************"
    echo
}

bannerSubSection() {
    title=$1
    echo
    echo -e "************** ${title} *******************"
    echo
}

bannerMessge() {
    title=$1
    echo
    echo -e "********************************"
    echo -e "${title}"
    echo -e "********************************"
    echo
}

setRed () {
    local input="$1"
    echo -e \\033[31m${input}\\033[0m
}
setGreen () {
    local input="$1"
    echo -e \\033[32m${input}\\033[0m
}
setYellow () {
    local input="$1"
    echo -e \\033[33m${input}\\033[0m
}

logger_addLinebreak () {
    echo -e "---\n"
}

bannerImportant() {
    title=$1
    local bold="\033[1m"
    local noColour="\033[0m"
    echo
    echo -e "${bold}######################################## IMPORTANT ########################################${noColour}"
    echo -e "${bold}${title}${noColour}"
    echo -e "${bold}###########################################################################################${noColour}"
    echo
}

bannerEnd() {
    #TODO pass a title and calculate length dynamically so that start and end look alike
    echo
    echo "*****************************************************************************"
    echo
}

banner() {
    title=$1
    content=$2
    bannerStart "${title}"
    echo -e "$content"
}

# The logic below helps us redirect content we'd normally hide to the log file. 
    #
    # We have several commands which clutter the console with output and so use 
    # `cmd > /dev/null` - this redirects the command's output to null.
    # 
    # However, the information we just hid maybe useful for support. Using the code pattern
    # `cmd >&6` (instead of `cmd> >/dev/null` ), the command's output is hidden from the console 
    # but redirected to the installation log file
    # 

#Default value of 6 is just null
exec 6>>/dev/null
redirectLogsToFile() {
    echo ""
    # local file=$1

    # [ ! -z "${file}" ] || return 0

    # local logDir=$(dirname "$file")

    # if [ ! -f "${file}" ]; then
    #     [ -d "${logDir}" ] || mkdir -p ${logDir} || \
    #     ( echo "WARNING : Could not create parent directory (${logDir}) to redirect console log : ${file}" ; return 0 )
    # fi

    # #6 now points to the log file
    # exec 6>>${file}
    # #reference https://unix.stackexchange.com/questions/145651/using-exec-and-tee-to-redirect-logs-to-stdout-and-a-log-file-in-the-same-time
    # exec 2>&1 > >(tee -a "${file}")
}

# Check if a give key contains any sensitive string as part of it
# Based on the result, the caller can decide its value can be displayed or not
#   Sample usage : isKeySensitive "${key}" && displayValue="******" || displayValue=${value}
isKeySensitive(){
    local key=$1
    local sensitiveKeys="password|secret|key|token"
    
    if [ -z "${key}" ]; then
        return 1
    else
        local lowercaseKey=$(echo "${key}" | tr '[:upper:]' '[:lower:]' 2>/dev/null)
        [[ "${lowercaseKey}" =~ ${sensitiveKeys} ]] && return 0 || return 1
    fi
}

getPrintableValueOfKey(){
    local displayValue=
    local key="$1"
    if [ -z "$key" ]; then
        # This is actually an incorrect usage of this method but any logging will cause unexpected content in the caller
        echo -n ""
        return
    fi

    local value="$2"
    isKeySensitive "${key}" && displayValue="$SENSITIVE_KEY_VALUE" || displayValue="${value}"
    echo -n $displayValue
}

_createConsoleLog(){
    if [ -z "${JF_PRODUCT_HOME}" ]; then
        return
    fi
    local targetFile="${JF_PRODUCT_HOME}/var/log/console.log"
    mkdir -p "${JF_PRODUCT_HOME}/var/log" || true
    if [ ! -f ${targetFile} ]; then
        touch $targetFile > /dev/null 2>&1 || true
    fi
    chmod 640 $targetFile > /dev/null 2>&1 || true
}

# Output from application's logs are piped to this method. It checks a configuration variable to determine if content should be logged to 
# the common console.log file
redirectServiceLogsToFile() {

    local result="0"
    # check if the function getSystemValue exists
    LC_ALL=C type getSystemValue > /dev/null 2>&1 || result="$?"
    if [[ "$result" != "0" ]]; then
        warn "Couldn't find the systemYamlHelper. Skipping log redirection"
        return 0
    fi

    getSystemValue "shared.consoleLog" "NOT_SET"
    if [[ "${YAML_VALUE}" == "false" ]]; then
        logger "Redirection is set to false. Skipping log redirection"
        return 0;
    fi

    if [ -z "${JF_PRODUCT_HOME}" ] || [ "${JF_PRODUCT_HOME}" == "" ]; then
        warn "JF_PRODUCT_HOME is unavailable. Skipping log redirection"
        return 0
    fi

    local targetFile="${JF_PRODUCT_HOME}/var/log/console.log"
    
    _createConsoleLog

    while read -r line; do
        printf '%s\n' "${line}" >> $targetFile || return 0 # Don't want to log anything - might clutter the screen
    done
}

## Display environment variables starting with JF_ along with its value
## Value of sensitive keys will be displayed as "******"
##
## Sample Display :
##
## ========================
## JF Environment variables
## ========================
##
## JF_SHARED_NODE_ID                   : locahost
## JF_SHARED_JOINKEY                   : ******
##
##
displayEnv() {
    local JFEnv=$(printenv | grep ^JF_ 2>/dev/null)
    local key=
    local value=

    if [ -z "${JFEnv}" ]; then
        return
    fi

    cat << ENV_START_MESSAGE

========================
JF Environment variables
========================
ENV_START_MESSAGE

    for entry in ${JFEnv}; do
        key=$(echo "${entry}" | awk -F'=' '{print $1}')
        value=$(echo "${entry}" | awk -F'=' '{print $2}')

        isKeySensitive "${key}" && value="******" || value=${value}
        
        printf "\n%-35s%s" "${key}" " : ${value}"
    done
    echo;
}

_addLogRotateConfiguration() {
    logDebug "Method ${FUNCNAME[0]}"
    # mandatory inputs
    local confFile="$1"
    local logFile="$2"

    # Method available in _ioOperations.sh
    LC_ALL=C type io_setYQPath > /dev/null 2>&1 || return 1

    io_setYQPath

    # Method available in _systemYamlHelper.sh
    LC_ALL=C type getSystemValue > /dev/null 2>&1 || return 1

    local frequency="daily"
    local archiveFolder="archived"

    local compressLogFiles=
    getSystemValue "shared.logging.rotation.compress" "true"
    if [[ "${YAML_VALUE}" == "true" ]]; then
        compressLogFiles="compress"
    fi

    getSystemValue "shared.logging.rotation.maxFiles" "10"
    local noOfBackupFiles="${YAML_VALUE}"

    getSystemValue "shared.logging.rotation.maxSizeMb" "25"
    local sizeOfFile="${YAML_VALUE}M"

    logDebug "Adding logrotate configuration for [$logFile] to [$confFile]"

    # Add configuration to file
    local confContent=$(cat << LOGROTATECONF
$logFile {
    $frequency
    missingok
    rotate $noOfBackupFiles
    $compressLogFiles
    notifempty
    olddir $archiveFolder
    dateext
    extension .log
    dateformat -%Y-%m-%d
    size ${sizeOfFile}
}
LOGROTATECONF
) 
    echo "${confContent}" > ${confFile} || return 1
}

_operationIsBySameUser() {
    local targetUser="$1"
    local currentUserID=$(id -u)
    local currentUserName=$(id -un)

    if [ $currentUserID == $targetUser ] || [ $currentUserName == $targetUser ]; then
        echo -n "yes"
    else   
        echo -n "no"
    fi
}

_addCronJobForLogrotate() {
    logDebug "Method ${FUNCNAME[0]}"
    
    # Abort if logrotate is not available
    [ "$(io_commandExists 'crontab')" != "yes" ] && warn "cron is not available" && return 1

    # mandatory inputs
    local productHome="$1"
    local confFile="$2"
    local cronJobOwner="$3"

    # We want to use our binary if possible. It may be more recent than the one in the OS
    local logrotateBinary="$productHome/app/third-party/logrotate/logrotate"

    if [ ! -f "$logrotateBinary" ]; then
        logrotateBinary="logrotate"
        [ "$(io_commandExists 'logrotate')" != "yes" ] && warn "logrotate is not available" && return 1
    fi
    local cmd="$logrotateBinary ${confFile} --state $productHome/var/etc/logrotate/logrotate-state" #--verbose

    id -u $cronJobOwner > /dev/null 2>&1 || { warn "User $cronJobOwner does not exist. Aborting logrotate configuration" && return 1; }
    
    # Remove the existing line
    removeLogRotation "$productHome" "$cronJobOwner" || true

    # Run logrotate daily at 23:55 hours
    local cronInterval="55 23 * * * $cmd"

    local standaloneMode=$(_operationIsBySameUser "$cronJobOwner")

    # If this is standalone mode, we cannot use -u - the user running this process may not have the necessary privileges
    if [ "$standaloneMode" == "no" ]; then
        (crontab -l -u $cronJobOwner 2>/dev/null; echo "$cronInterval") | crontab -u $cronJobOwner -
    else
        (crontab -l 2>/dev/null; echo "$cronInterval") | crontab -
    fi
}

## Configure logrotate for a product
## Failure conditions:
## If logrotation could not be setup for some reason
## Parameters:
## $1: The product name
## $2: The product home
## Depends on global: none
## Updates global: none
## Returns: NA

configureLogRotation() {
    logDebug "Method ${FUNCNAME[0]}"

    # mandatory inputs
    local productName="$1"
    if [ -z $productName ]; then
        warn "Incorrect usage. A product name is necessary for configuring log rotation" && return 1
    fi
    
    local productHome="$2"
    if [ -z $productHome ]; then
        warn "Incorrect usage. A product home folder is necessary for configuring log rotation" && return 1
    fi

    local logFile="${productHome}/var/log/console.log"
    if [[ $(uname) == "Darwin" ]]; then
        logger "Log rotation for [$logFile] has not been configured. Please setup manually"
        return 0
    fi
    
    local userID="$3"
    if [ -z $userID ]; then
        warn "Incorrect usage. A userID is necessary for configuring log rotation" && return 1
    fi

    local groupID=${4:-$userID}
    local logConfigOwner=${5:-$userID}

    logDebug "Configuring log rotation as user [$userID], group [$groupID], effective cron User [$logConfigOwner]"
    
    local errorMessage="Could not configure logrotate. Please configure log rotation of the file: [$logFile] manually"

    local confFile="${productHome}/var/etc/logrotate/logrotate.conf"

    # TODO move to recursive method
    createDir "${productHome}" "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    createDir "${productHome}/var" "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    createDir "${productHome}/var/log" "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    createDir "${productHome}/var/log/archived" "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    
    # TODO move to recursive method
    createDir "${productHome}/var/etc"  "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    createDir "${productHome}/var/etc/logrotate" "$logConfigOwner" || { warn "${errorMessage}" && return 1; }

    # conf file should be owned by the user running the script
    createFile "${confFile}" "${logConfigOwner}" || { warn "Could not create configuration file [$confFile]" return 1; }

    _addLogRotateConfiguration "${confFile}" "${logFile}" "$userID" "$groupID" || { warn "${errorMessage}" && return 1; }
    _addCronJobForLogrotate "${productHome}" "${confFile}" "${logConfigOwner}" || { warn "${errorMessage}" && return 1; }
}

_pauseExecution() {
    if [ "${VERBOSE_MODE}" == "debug" ]; then
        
        local breakPoint="$1"
        if [ ! -z "$breakPoint" ]; then
            printf "${cBlue}Breakpoint${cClear} [$breakPoint] "
            echo ""
        fi
        printf "${cBlue}Press enter once you are ready to continue${cClear}"
        read -s choice
        echo ""
    fi
}

# removeLogRotation "$productHome" "$cronJobOwner" || true
removeLogRotation() {
    logDebug "Method ${FUNCNAME[0]}"
    if [[ $(uname) == "Darwin" ]]; then
        logDebug "Not implemented for Darwin."
        return 0
    fi
    local productHome="$1"
    local cronJobOwner="$2"
    local standaloneMode=$(_operationIsBySameUser "$cronJobOwner")

    local confFile="${productHome}/var/etc/logrotate/logrotate.conf"
    
    if [ "$standaloneMode" == "no" ]; then
        crontab -l -u $cronJobOwner 2>/dev/null | grep -v "$confFile" | crontab -u $cronJobOwner -
    else
        crontab -l 2>/dev/null | grep -v "$confFile" | crontab -
    fi
}

# NOTE: This method does not check the configuration to see if redirection is necessary.
# This is intentional. If we don't redirect, tomcat logs might get redirected to a folder/file
# that does not exist, causing the service itself to not start
setupTomcatRedirection() {
    logDebug "Method ${FUNCNAME[0]}"
    local consoleLog="${JF_PRODUCT_HOME}/var/log/console.log"
    _createConsoleLog
    export CATALINA_OUT="${consoleLog}"
}

setupScriptLogsRedirection() {
    logDebug "Method ${FUNCNAME[0]}"
    if [ -z "${JF_PRODUCT_HOME}" ]; then
        logDebug "No JF_PRODUCT_HOME. Returning"
        return
    fi
    # Create the console.log file if it is not already present
    # _createConsoleLog || true
    # # Ensure any logs (logger/logError/warn) also get redirected to the console.log
    # # Using installer.log as a temparory fix. Please change this to console.log once INST-291 is fixed
    export LOG_BEHAVIOR_ADD_REDIRECTION="${JF_PRODUCT_HOME}/var/log/console.log"
    export LOG_BEHAVIOR_ADD_META="$FLAG_Y"
}

# Returns Y if this method is run inside a container
isRunningInsideAContainer() {
    if [ -f "/.dockerenv" ]; then
        echo -n "$FLAG_Y"
    else
        echo -n "$FLAG_N"
    fi 
}

POSTGRES_USER=999
NGINX_USER=104
NGINX_GROUP=107
ES_USER=1000
REDIS_USER=999
MONGO_USER=999
RABBITMQ_USER=999
LOG_FILE_PERMISSION=640
PID_FILE_PERMISSION=644

# Copy file
copyFile(){
    local source=$1
    local target=$2
    local mode=${3:-overwrite}
    local enableVerbose=${4:-"${FLAG_N}"}
    local verboseFlag=""

    if [ ! -z "${enableVerbose}" ] && [ "${enableVerbose}" == "${FLAG_Y}" ]; then
        verboseFlag="-v"
    fi

    if [[ ! ( $source && $target ) ]]; then
        warn "Source and target is mandatory to copy file"
        return 1
    fi

    if [[ -f "${target}" ]]; then
        [[ "$mode" = "overwrite" ]] && ( cp ${verboseFlag} -f "$source" "$target" || errorExit "Unable to copy file, command : cp -f ${source} ${target}") || true
    else
        cp ${verboseFlag} -f "$source" "$target" || errorExit "Unable to copy file, command : cp -f ${source} ${target}"
    fi
}

# Copy files recursively from given source directory to destination directory
# This method wil copy but will NOT overwrite
# Destination will be created if its not available
copyFilesNoOverwrite(){
    local src=$1
    local dest=$2
    local enableVerboseCopy="${3:-${FLAG_Y}}"

    if [[ -z "${src}" || -z "${dest}" ]]; then
        return
    fi

    if [ -d "${src}" ] && [ "$(ls -A ${src})" ]; then
        local relativeFilePath=""
        local targetFilePath=""

        for file in $(find ${src} -type f 2>/dev/null) ; do
            # Derive relative path and attach it to destination 
            # Example : 
            #       src=/extra_config
            #       dest=/var/opt/jfrog/artifactory/etc
            #       file=/extra_config/config.xml
            #       relativeFilePath=config.xml
            #       targetFilePath=/var/opt/jfrog/artifactory/etc/config.xml
            relativeFilePath=${file/${src}/}
            targetFilePath=${dest}${relativeFilePath}

            createDir "$(dirname "$targetFilePath")"
            copyFile "${file}" "${targetFilePath}" "no_overwrite" "${enableVerboseCopy}"
        done
    fi    
}

#    TODO : WINDOWS ?
#  Check the max open files and open processes set on the system
checkULimits () {
    local minMaxOpenFiles=${1:-32000}
    local minMaxOpenProcesses=${2:-1024}
    local setValue=${3:-true}
    local warningMsgForFiles=${4}
    local warningMsgForProcesses=${5}

    logger "Checking open files and processes limits"

    local currentMaxOpenFiles=$(ulimit -n)
    logger "Current max open files is $currentMaxOpenFiles"
    if [ ${currentMaxOpenFiles} != "unlimited" ] && [ "$currentMaxOpenFiles" -lt "$minMaxOpenFiles" ]; then
        if [ "${setValue}" ]; then
            ulimit -n "${minMaxOpenFiles}" >/dev/null 2>&1 || warn "Max number of open files $currentMaxOpenFiles is low!"
            [ -z "${warningMsgForFiles}" ] || warn "${warningMsgForFiles}"
        else
            errorExit "Max number of open files $currentMaxOpenFiles, is too low. Cannot run the application!"
        fi
    fi

    local currentMaxOpenProcesses=$(ulimit -u)
    logger "Current max open processes is $currentMaxOpenProcesses"
    if [ "$currentMaxOpenProcesses" != "unlimited" ] && [ "$currentMaxOpenProcesses" -lt "$minMaxOpenProcesses" ]; then
        if [ "${setValue}" ]; then
            ulimit -u "${minMaxOpenProcesses}" >/dev/null 2>&1 || warn "Max number of open files $currentMaxOpenFiles is low!"
            [ -z "${warningMsgForProcesses}" ] || warn "${warningMsgForProcesses}"
        else
            errorExit "Max number of open files $currentMaxOpenProcesses, is too low. Cannot run the application!"
        fi
    fi
}

createDirs() {
    local appDataDir=$1
    local serviceName=$2
    local folders="backup bootstrap data etc logs work"

    [ -z "${appDataDir}" ]  && errorExit "An application directory is mandatory to create its data structure"  || true
    [ -z "${serviceName}" ] && errorExit "A service name is mandatory to create service data structure"         || true

    for folder in ${folders}
    do
        folder=${appDataDir}/${folder}/${serviceName}
        if [ ! -d "${folder}" ]; then
            logger "Creating folder : ${folder}"
            mkdir -p "${folder}" || errorExit "Failed to create ${folder}"
        fi
    done
}


testReadWritePermissions () {
    local dir_to_check=$1
    local error=false

    [ -d ${dir_to_check} ] || errorExit "'${dir_to_check}' is not a directory"

    local test_file=${dir_to_check}/test-permissions

    # Write file
    if echo test > ${test_file} 1> /dev/null 2>&1; then
        # Write succeeded. Testing read...
        if cat ${test_file} > /dev/null; then
            rm -f ${test_file}
        else
            error=true
        fi
    else
        error=true
    fi

    if [ ${error} == true ]; then
        return 1
    else
        return 0
    fi
}

# Test directory has read/write permissions for current user
testDirectoryPermissions () {
    local dir_to_check=$1
    local error=false

    [ -d ${dir_to_check}  ] || errorExit "'${dir_to_check}' is not a directory"

    local u_id=$(id -u)
    local id_str="id ${u_id}"

    logger "Testing directory ${dir_to_check} has read/write permissions for user ${id_str}"

    if ! testReadWritePermissions ${dir_to_check}; then
        error=true
    fi

    if [ "${error}" == true ]; then
        local stat_data=$(stat -Lc "Directory: %n, permissions: %a, owner: %U, group: %G" ${dir_to_check})
        logger "###########################################################"
        logger "${dir_to_check} DOES NOT have proper permissions for user ${id_str}"
        logger "${stat_data}"
        logger "Mounted directory must have read/write permissions for user ${id_str}"
        logger "###########################################################"
        errorExit "Directory ${dir_to_check} has bad permissions for user ${id_str}"
    fi
    logger "Permissions for ${dir_to_check} are good"
}

# Utility method to create a directory path recursively with chown feature as
# Failure conditions:
## Exits if unable to create a directory
# Parameters:
## $1: Root directory from where the path can be created
## $2: List of recursive child directories seperated by space
## $3: user who should own the directory. Optional
## $4: group who should own the directory. Optional
# Depends on global: none
# Updates global: none
# Returns: NA
#
# Usage:
# createRecursiveDir "/opt/jfrog/product/var" "bootstrap tomcat lib" "user_name" "group_name"
createRecursiveDir(){
    local rootDir=$1
    local pathDirs=$2
    local user=$3
    local group=${4:-${user}}
    local fullPath=

    [ ! -z "${rootDir}" ] || return 0

    createDir "${rootDir}" "${user}" "${group}"

    [ ! -z "${pathDirs}" ] || return 0

    fullPath=${rootDir}

    for dir in ${pathDirs}; do
        fullPath=${fullPath}/${dir}
        createDir "${fullPath}" "${user}" "${group}"
    done
}

# Utility method to create a directory
# Failure conditions:
## Exits if unable to create a directory
# Parameters:
## $1: directory to create
## $2: user who should own the directory. Optional
## $3: group who should own the directory. Optional
# Depends on global: none
# Updates global: none
# Returns: NA

createDir(){
    local dirName="$1"
    local printMessage=no
    logSilly "Method ${FUNCNAME[0]} invoked with [$dirName]"
    [ -z "${dirName}" ] && return
    
    logDebug "Attempting to create ${dirName}"
    mkdir -p "${dirName}" || errorExit "Unable to create directory: [${dirName}]"
    local userID="$2"
    local groupID=${3:-$userID}

    # If UID/GID is passed, chown the folder
    if [ ! -z "$userID" ] && [ ! -z "$groupID" ]; then
        # Earlier, this line would have returned 1 if it failed. Now it just warns. 
        # This is intentional. Earlier, this line would NOT be reached if the folder already existed. 
        # Since it will always come to this line and the script may be running as a non-root user, this method will just warn if
        # setting permissions fails (so as to not affect any existing flows)
        io_setOwnershipNonRecursive "$dirName" "$userID" "$groupID" || warn "Could not set owner of [$dirName] to [$userID:$groupID]"
    fi
    # logging message to print created dir with user and group
    local logMessage=${4:-$printMessage}
    if [[ "${logMessage}" == "yes" ]]; then
        logger "Successfully created directory [${dirName}].  Owner: [${userID}:${groupID}]"
    fi
}

removeSoftLinkAndCreateDir () {
    local dirName="$1"
    local userID="$2"
    local groupID="$3"
    local logMessage="$4"
    removeSoftLink "${dirName}"
    createDir "${dirName}" "${userID}" "${groupID}" "${logMessage}"
}

# Utility method to remove a soft link
removeSoftLink () {
    local dirName="$1"
    if [[ -L "${dirName}" ]]; then
        targetLink=$(readlink -f "${dirName}")
        logger "Removing the symlink [${dirName}] pointing to [${targetLink}]"
        rm -f "${dirName}"
    fi
}

# Check Directory exist in the path
checkDirExists () {
    local directoryPath="$1"

    [[ -d "${directoryPath}" ]] && echo -n "true" || echo -n "false"
}


# Utility method to create a file
# Failure conditions:
# Parameters:
## $1: file to create
# Depends on global: none
# Updates global: none
# Returns: NA

createFile(){
    local fileName="$1"
    logSilly "Method ${FUNCNAME[0]} [$fileName]"
    [ -f "${fileName}" ] && return 0
    touch "${fileName}" || return 1

    local userID="$2"
    local groupID=${3:-$userID}

    # If UID/GID is passed, chown the folder
    if [ ! -z "$userID" ] && [ ! -z "$groupID" ]; then
        io_setOwnership "$fileName" "$userID" "$groupID" || return 1
    fi
}

# Check File exist in the filePath
# IMPORTANT- DON'T ADD LOGGING to this method
checkFileExists () {
    local filePath="$1"

    [[ -f "${filePath}" ]] && echo -n "true" || echo -n "false"
}

# Check for directories contains any (files or sub directories)
# IMPORTANT- DON'T ADD LOGGING to this method
checkDirContents () {
    local directoryPath="$1"
    if [[ "$(ls -1 "${directoryPath}" | wc -l)" -gt 0 ]]; then
        echo -n "true"
    else
        echo -n "false"
    fi
}

# Check contents exist in directory
# IMPORTANT- DON'T ADD LOGGING to this method
checkContentExists () {
    local source="$1"

    if [[ "$(checkDirContents "${source}")" != "true" ]]; then
        echo -n "false"
    else
        echo -n "true"
    fi
}

# Resolve the variable
# IMPORTANT- DON'T ADD LOGGING to this method
evalVariable () {
    local output="$1"
    local input="$2"

    eval "${output}"=\${"${input}"}
    eval echo \${"${output}"}
}

# Usage: if [ "$(io_commandExists 'curl')" == "yes" ]
# IMPORTANT- DON'T ADD LOGGING to this method
io_commandExists() {
    local commandToExecute="$1"
    hash "${commandToExecute}" 2>/dev/null
    local rt=$?
    if [ "$rt" == 0 ]; then echo -n "yes"; else echo -n "no"; fi
}

# Usage: if [ "$(io_curlExists)" != "yes" ]
# IMPORTANT- DON'T ADD LOGGING to this method
io_curlExists() {
    io_commandExists "curl"
}


io_hasMatch() {
    logSilly "Method ${FUNCNAME[0]}"
    local result=0
    logDebug "Executing [echo \"$1\" | grep \"$2\" >/dev/null 2>&1]"
    echo "$1" | grep "$2" >/dev/null 2>&1 || result=1
    return $result
}

# Utility method to check if the string passed (usually a connection url) corresponds to this machine itself
# Failure conditions: None
# Parameters:
## $1: string to check against
# Depends on global: none
# Updates global: IS_LOCALHOST with value "yes/no"
# Returns: NA

io_getIsLocalhost() {
    logSilly "Method ${FUNCNAME[0]}"
    IS_LOCALHOST="$FLAG_N"
    local inputString="$1"
    logDebug "Parsing [$inputString] to check if we are dealing with this machine itself"

    io_hasMatch "$inputString" "localhost" && {
        logDebug "Found localhost. Returning [$FLAG_Y]"
        IS_LOCALHOST="$FLAG_Y" && return;
    } || logDebug "Did not find match for localhost"
    
    local hostIP=$(io_getPublicHostIP)
    io_hasMatch "$inputString" "$hostIP" && {
        logDebug "Found $hostIP. Returning [$FLAG_Y]"
        IS_LOCALHOST="$FLAG_Y" && return;
    } || logDebug "Did not find match for $hostIP"
    
    local hostID=$(io_getPublicHostID)
    io_hasMatch "$inputString" "$hostID" && {
        logDebug "Found $hostID. Returning [$FLAG_Y]"
        IS_LOCALHOST="$FLAG_Y" && return;
    } || logDebug "Did not find match for $hostID"
    
    local hostName=$(io_getPublicHostName)
    io_hasMatch  "$inputString" "$hostName" && {
        logDebug "Found $hostName. Returning [$FLAG_Y]"
        IS_LOCALHOST="$FLAG_Y" && return;
    } || logDebug "Did not find match for $hostName"
    
}

# Usage: if [ "$(io_tarExists)" != "yes" ]
# IMPORTANT- DON'T ADD LOGGING to this method
io_tarExists() {
    io_commandExists "tar"
}

# IMPORTANT- DON'T ADD LOGGING to this method
io_getPublicHostIP() {
    local OS_TYPE=$(uname)
    local publicHostIP=
    if [ "${OS_TYPE}" == "Darwin" ]; then
        ipStatus=$(ifconfig en0 | grep "status" | awk '{print$2}')
        if [ "${ipStatus}" == "active" ]; then
            publicHostIP=$(ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}')
        else
            errorExit "Host IP could not be resolved!"
        fi
    elif [ "${OS_TYPE}" == "Linux" ]; then
        publicHostIP=$(hostname -i 2>/dev/null || echo "127.0.0.1")
    fi
    publicHostIP=$(echo "${publicHostIP}" | awk '{print $1}')
    echo -n "${publicHostIP}"
}

# Will return the short host name (up to the first dot)
# IMPORTANT- DON'T ADD LOGGING to this method
io_getPublicHostName() {
    echo -n "$(hostname -s)"
}

# Will return the full host name (use this as much as possible)
# IMPORTANT- DON'T ADD LOGGING to this method
io_getPublicHostID() {
    echo -n "$(hostname)"
}

# Utility method to backup a file
# Failure conditions: NA
# Parameters: filePath
# Depends on global: none,
# Updates global: none
# Returns: NA
io_backupFile() {
    logSilly "Method ${FUNCNAME[0]}"
    fileName="$1"
    if [ ! -f "${filePath}" ]; then
        logDebug "No file: [${filePath}] to backup"
        return
    fi
    dateTime=$(date +"%Y-%m-%d-%H-%M-%S")
    targetFileName="${fileName}.backup.${dateTime}"
    yes | \cp -f "$fileName" "${targetFileName}"
    logger "File [${fileName}] backedup as [${targetFileName}]"
}

# Reference https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash/4025065#4025065
is_number() {
    case "$BASH_VERSION" in
        3.1.*)
            PATTERN='\^\[0-9\]+\$'
            ;;
        *)
            PATTERN='^[0-9]+$'
            ;;
    esac

    [[ "$1" =~ $PATTERN ]]
}

io_compareVersions() {
    if [[ $# != 2 ]]
    then
        echo "Usage: min_version current minimum"
        return
    fi

    A="${1%%.*}"
    B="${2%%.*}"

    if [[ "$A" != "$1" && "$B" != "$2" && "$A" == "$B" ]]
    then
        io_compareVersions "${1#*.}" "${2#*.}"
    else
        if is_number "$A" && is_number "$B"
        then
            if [[ "$A" -eq "$B" ]]; then
                echo "0"
            elif [[ "$A" -gt "$B" ]]; then
                echo "1"
            elif [[ "$A" -lt "$B" ]]; then
                echo "-1"
            fi
        fi
    fi
}

# Reference https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
# Strip all leading and trailing spaces
# IMPORTANT- DON'T ADD LOGGING to this method
io_trim() {
    local var="$1"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# temporary function will be removing it ASAP
# search for string and replace text in file
replaceText_migration_hook () {
    local regexString="$1"
    local replaceText="$2"
    local file="$3"

    if [[ "$(checkFileExists "${file}")" != "true" ]]; then
        return
    fi
    if [[ $(uname) == "Darwin" ]]; then
        sed -i '' -e "s/${regexString}/${replaceText}/" "${file}" || warn "Failed to replace the text in ${file}"
    else
        sed -i -e "s/${regexString}/${replaceText}/" "${file}" || warn "Failed to replace the text in ${file}"
    fi
}

# search for string and replace text in file
replaceText () {
    local regexString="$1"
    local replaceText="$2"
    local file="$3"

    if [[ "$(checkFileExists "${file}")" != "true" ]]; then
        return
    fi
    if [[ $(uname) == "Darwin" ]]; then
        sed -i '' -e "s#${regexString}#${replaceText}#" "${file}" || warn "Failed to replace the text in ${file}"
    else
        sed -i -e "s#${regexString}#${replaceText}#" "${file}" || warn "Failed to replace the text in ${file}"
        logDebug "Replaced [$regexString] with [$replaceText] in [$file]"
    fi
}

# search for string and prepend text in file
prependText () {
    local regexString="$1"
    local text="$2"
    local file="$3"

    if [[ "$(checkFileExists "${file}")" != "true" ]]; then
        return
    fi
    if [[ $(uname) == "Darwin" ]]; then
        sed -i '' -e '/'"${regexString}"'/i\'$'\n\\'"${text}"''$'\n' "${file}" || warn "Failed to prepend the text in ${file}"
    else
        sed -i -e '/'"${regexString}"'/i\'$'\n\\'"${text}"''$'\n' "${file}" || warn "Failed to prepend the text in ${file}"
    fi
}

# add text to beginning of the file
addText () {
    local text="$1"
    local file="$2"

    if [[ "$(checkFileExists "${file}")" != "true" ]]; then
        return
    fi
    if [[ $(uname) == "Darwin" ]]; then
        sed -i '' -e '1s/^/'"${text}"'\'$'\n/' "${file}" || warn "Failed to add the text in ${file}"
    else
        sed -i -e '1s/^/'"${text}"'\'$'\n/' "${file}" || warn "Failed to add the text in ${file}"
    fi
}

io_replaceString () {
    local value="$1"
    local firstString="$2"
    local secondString="$3"
    local separator=${4:-"/"}
    local updateValue=
    if [[ $(uname) == "Darwin" ]]; then
        updateValue=$(echo "${value}" | sed "s${separator}${firstString}${separator}${secondString}${separator}")
    else
        updateValue=$(echo "${value}" | sed "s${separator}${firstString}${separator}${secondString}${separator}")
    fi
    echo -n "${updateValue}"
}

_findYQ() {
    # logSilly "Method ${FUNCNAME[0]}" (Intentionally not logging. Does not add value)
    local parentDir="$1"
    if [ -z "$parentDir" ]; then
        return
    fi
    logDebug "Executing command [find "${parentDir}" -name third-party -type d]"
    local yq=$(find "${parentDir}" -name third-party -type d)
    if [ -d "${yq}/yq" ]; then
        export YQ_PATH="${yq}/yq"
    fi
}


io_setYQPath() {
    # logSilly "Method ${FUNCNAME[0]}" (Intentionally not logging. Does not add value)
    if [ "$(io_commandExists 'yq')" == "yes" ]; then
        return
    fi
    
    if [ ! -z "${JF_PRODUCT_HOME}" ] && [ -d "${JF_PRODUCT_HOME}" ]; then
        _findYQ "${JF_PRODUCT_HOME}"
    fi
    
    if [ -z "${YQ_PATH}" ] && [ ! -z "${COMPOSE_HOME}" ] && [ -d "${COMPOSE_HOME}" ]; then
        _findYQ "${COMPOSE_HOME}"
    fi
    # TODO We can remove this block after all the code is restructured.
    if [ -z "${YQ_PATH}" ] && [ ! -z "${SCRIPT_HOME}" ] && [ -d "${SCRIPT_HOME}" ]; then
        _findYQ "${SCRIPT_HOME}"
    fi
    
}

io_getLinuxDistribution() {
    LINUX_DISTRIBUTION=

    # Make sure running on Linux
    [ $(uname -s) != "Linux" ] && return

    # Find out what Linux distribution we are on

    cat /etc/*-release | grep -i Red >/dev/null 2>&1 && LINUX_DISTRIBUTION=RedHat || true

    # OS 6.x
    cat /etc/issue.net | grep Red >/dev/null 2>&1 && LINUX_DISTRIBUTION=RedHat || true

    # OS 7.x
    cat /etc/*-release | grep -i centos >/dev/null 2>&1 && LINUX_DISTRIBUTION=CentOS && LINUX_DISTRIBUTION_VER="7" || true

    # OS 8.x
    grep -q -i "release 8" /etc/redhat-release >/dev/null 2>&1 && LINUX_DISTRIBUTION_VER="8" || true

    # OS 7.x
    grep -q -i "release 7" /etc/redhat-release >/dev/null 2>&1 && LINUX_DISTRIBUTION_VER="7" || true

    # OS 6.x
    grep -q -i "release 6" /etc/redhat-release >/dev/null 2>&1 && LINUX_DISTRIBUTION_VER="6" || true

    cat /etc/*-release | grep -i Red | grep -i 'VERSION=7' >/dev/null 2>&1 && LINUX_DISTRIBUTION=RedHat && LINUX_DISTRIBUTION_VER="7" || true

    cat /etc/*-release | grep -i debian >/dev/null 2>&1 && LINUX_DISTRIBUTION=Debian || true

    cat /etc/*-release | grep -i ubuntu >/dev/null 2>&1 && LINUX_DISTRIBUTION=Ubuntu || true
}

## Utility method to check ownership of folders/files
## Failure conditions:
    ## If invoked with incorrect inputs - FATAL
    ## If file is not owned by the user & group
## Parameters:
    ## user
    ## group
    ## folder to chown    
## Globals: none
## Returns: none
## NOTE: The method does NOTHING if the OS is Mac
io_checkOwner () {
    logSilly "Method ${FUNCNAME[0]}"
    local osType=$(uname)
    
    if [ "${osType}" != "Linux" ]; then
        logDebug "Unsupported OS. Skipping check"
        return 0
    fi

    local file_to_check=$1
    local user_id_to_check=$2
    

    if [ -z "$user_id_to_check" ] || [ -z "$file_to_check" ]; then
        errorExit "Invalid invocation of method. Missing mandatory inputs"
    fi

    local group_id_to_check=${3:-$user_id_to_check}
    local check_user_name=${4:-"no"}

    logDebug "Checking permissions on [$file_to_check] for user [$user_id_to_check] & group [$group_id_to_check]"

    local stat=

    if [ "${check_user_name}" == "yes" ]; then
        stat=( $(stat -Lc "%U %G" ${file_to_check}) )
    else
        stat=( $(stat -Lc "%u %g" ${file_to_check}) )
    fi

    local user_id=${stat[0]}
    local group_id=${stat[1]}

    if [[ "${user_id}" != "${user_id_to_check}" ]] || [[ "${group_id}" != "${group_id_to_check}" ]] ; then
        logDebug "Ownership mismatch. [${file_to_check}] is not owned by [${user_id_to_check}:${group_id_to_check}]"
        return 1
    else
        return 0
    fi
}

## Utility method to change ownership of a file/folder - NON recursive
## Failure conditions:
    ## If invoked with incorrect inputs - FATAL
    ## If chown operation fails - returns 1
## Parameters: 
    ## user
    ## group
    ## file to chown    
## Globals: none
## Returns: none
## NOTE: The method does NOTHING if the OS is Mac

io_setOwnershipNonRecursive() {
    
    local osType=$(uname)
    if [ "${osType}" != "Linux" ]; then
        return
    fi

    local targetFile=$1
    local user=$2

    if [ -z "$user" ] || [ -z "$targetFile" ]; then
        errorExit "Invalid invocation of method. Missing mandatory inputs"
    fi

    local group=${3:-$user}
    logDebug "Method ${FUNCNAME[0]}. Executing [chown ${user}:${group} ${targetFile}]"
    chown ${user}:${group} ${targetFile} || return 1
}

## Utility method to change ownership of a file. 
## IMPORTANT 
## If being called on a folder, should ONLY be called for fresh folders or may cause performance issues
## Failure conditions:
    ## If invoked with incorrect inputs - FATAL
    ## If chown operation fails - returns 1
## Parameters: 
    ## user
    ## group
    ## file to chown    
## Globals: none
## Returns: none
## NOTE: The method does NOTHING if the OS is Mac

io_setOwnership() {
    
    local osType=$(uname)
    if [ "${osType}" != "Linux" ]; then
        return
    fi

    local targetFile=$1
    local user=$2

    if [ -z "$user" ] || [ -z "$targetFile" ]; then
        errorExit "Invalid invocation of method. Missing mandatory inputs"
    fi

    local group=${3:-$user}
    logDebug "Method ${FUNCNAME[0]}. Executing [chown -R ${user}:${group} ${targetFile}]"
    chown -R ${user}:${group} ${targetFile} || return 1
}

## Utility method to create third party folder structure necessary for Postgres
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## POSTGRESQL_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createPostgresDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${POSTGRESQL_DATA_ROOT}" ] && return 0

    logDebug "Property [${POSTGRESQL_DATA_ROOT}] exists. Proceeding"

    createDir "${POSTGRESQL_DATA_ROOT}/data"
    io_setOwnership  "${POSTGRESQL_DATA_ROOT}" "${POSTGRES_USER}" "${POSTGRES_USER}" || errorExit "Setting ownership of [${POSTGRESQL_DATA_ROOT}] to [${POSTGRES_USER}:${POSTGRES_USER}] failed"
}

## Utility method to create third party folder structure necessary for Nginx
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## NGINX_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createNginxDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${NGINX_DATA_ROOT}" ] && return 0

    logDebug "Property [${NGINX_DATA_ROOT}] exists. Proceeding"

    createDir "${NGINX_DATA_ROOT}"
    io_setOwnership  "${NGINX_DATA_ROOT}" "${NGINX_USER}" "${NGINX_GROUP}" || errorExit "Setting ownership of [${NGINX_DATA_ROOT}] to [${NGINX_USER}:${NGINX_GROUP}] failed"
}

## Utility method to create third party folder structure necessary for ElasticSearch
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## ELASTIC_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createElasticSearchDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${ELASTIC_DATA_ROOT}" ] && return 0

    logDebug "Property [${ELASTIC_DATA_ROOT}] exists. Proceeding"

    createDir "${ELASTIC_DATA_ROOT}/data"
    io_setOwnership  "${ELASTIC_DATA_ROOT}" "${ES_USER}" "${ES_USER}" || errorExit "Setting ownership of [${ELASTIC_DATA_ROOT}] to [${ES_USER}:${ES_USER}] failed"
}

## Utility method to create third party folder structure necessary for Redis
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## REDIS_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createRedisDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${REDIS_DATA_ROOT}" ] && return 0

    logDebug "Property [${REDIS_DATA_ROOT}] exists. Proceeding"

    createDir "${REDIS_DATA_ROOT}"
    io_setOwnership  "${REDIS_DATA_ROOT}" "${REDIS_USER}" "${REDIS_USER}" || errorExit "Setting ownership of [${REDIS_DATA_ROOT}] to [${REDIS_USER}:${REDIS_USER}] failed"
}

## Utility method to create third party folder structure necessary for Mongo
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## MONGODB_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createMongoDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${MONGODB_DATA_ROOT}" ] && return 0

    logDebug "Property [${MONGODB_DATA_ROOT}] exists. Proceeding"

    createDir "${MONGODB_DATA_ROOT}/logs"
    createDir "${MONGODB_DATA_ROOT}/configdb"
    createDir "${MONGODB_DATA_ROOT}/db"
    io_setOwnership  "${MONGODB_DATA_ROOT}" "${MONGO_USER}" "${MONGO_USER}" || errorExit "Setting ownership of [${MONGODB_DATA_ROOT}] to [${MONGO_USER}:${MONGO_USER}] failed"
}

## Utility method to create third party folder structure necessary for RabbitMQ
## Failure conditions:
## If creation of directory or assigning permissions fails
## Parameters: none
## Globals:
## RABBITMQ_DATA_ROOT
## Returns: none
## NOTE: The method does NOTHING if the folder already exists
io_createRabbitMQDir() {
    logDebug "Method ${FUNCNAME[0]}"
    [ -z "${RABBITMQ_DATA_ROOT}" ] && return 0

    logDebug "Property [${RABBITMQ_DATA_ROOT}] exists. Proceeding"

    createDir "${RABBITMQ_DATA_ROOT}"
    io_setOwnership  "${RABBITMQ_DATA_ROOT}" "${RABBITMQ_USER}" "${RABBITMQ_USER}" || errorExit "Setting ownership of [${RABBITMQ_DATA_ROOT}] to [${RABBITMQ_USER}:${RABBITMQ_USER}] failed"
}

# Add or replace a property in provided properties file
addOrReplaceProperty() {
    local propertyName=$1
    local propertyValue=$2
    local propertiesPath=$3
    local delimiter=${4:-"="}

    # Return if any of the inputs are empty
    [[ -z "$propertyName"   || "$propertyName"   == "" ]] && return
    [[ -z "$propertyValue"  || "$propertyValue"  == "" ]] && return
    [[ -z "$propertiesPath" || "$propertiesPath" == "" ]] && return

    grep "^${propertyName}\s*${delimiter}.*$" ${propertiesPath} > /dev/null 2>&1
    [ $? -ne 0 ] && echo -e "\n${propertyName}${delimiter}${propertyValue}" >> ${propertiesPath}
    sed -i -e "s|^${propertyName}\s*${delimiter}.*$|${propertyName}${delimiter}${propertyValue}|g;" ${propertiesPath}
}

# Set property only if its not set
io_setPropertyNoOverride(){
    local propertyName=$1
    local propertyValue=$2
    local propertiesPath=$3

    # Return if any of the inputs are empty
    [[ -z "$propertyName"   || "$propertyName"   == "" ]] && return
    [[ -z "$propertyValue"  || "$propertyValue"  == "" ]] && return
    [[ -z "$propertiesPath" || "$propertiesPath" == "" ]] && return

    grep "^${propertyName}:" ${propertiesPath} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${propertyName}: ${propertyValue}" >> ${propertiesPath} || warn "Setting property ${propertyName}: ${propertyValue} in [ ${propertiesPath} ] failed"
    else
        logger "Skipping update of property : ${propertyName}" >&6
    fi
}

# Add a line to a file if it doesn't already exist
addLine() {
    local line_to_add=$1
    local target_file=$2
    logger "Trying to add line $1 to $2" >&6 2>&1
    cat "$target_file" | grep -F "$line_to_add" -wq >&6 2>&1
    if [ $? != 0  ]; then
        logger "Line does not exist and will be added" >&6 2>&1
        echo $line_to_add >> $target_file || errorExit "Could not update $target_file"
    fi    
}

# Utility method to check if a value (first paramter) exists in an array (2nd parameter)
# 1st parameter "value to find"
# 2nd parameter "The array to search in. Please pass a string with each value separated by space"
# Example: containsElement "y" "y Y n N"
containsElement () {
    local searchElement=$1
    local searchArray=($2)
    local found=1
    for elementInIndex in "${searchArray[@]}";do
    if [[ $elementInIndex == $searchElement ]]; then
        found=0
    fi
    done
    return $found
}

# Utility method to get user's choice
# 1st parameter "what to ask the user"
# 2nd parameter "what choices to accept, separated by spaces"
# 3rd parameter "what is the default choice (to use if the user simply presses Enter)"
# Example 'getUserChoice "Are you feeling lucky? Punk!" "y n Y N" "y"'
getUserChoice(){
    configureLogOutput
    read_timeout=${read_timeout:-0.5}
    local choice="na"
    local text_to_display=$1
    local choices=$2
    local default_choice=$3
    users_choice=

    until containsElement "$choice" "$choices"; do
        echo "";echo "";
        sleep $read_timeout #This ensures correct placement of the question.
        read -p  "$text_to_display :" choice
        : ${choice:=$default_choice}
    done
    users_choice=$choice
    echo -e "\n$text_to_display: $users_choice" >&6
    sleep $read_timeout #This ensures correct logging
}

setFilePermission () {
    local permission=$1
    local file=$2
    chmod "${permission}" "${file}" || warn "Setting permission ${permission} to file [ ${file} ] failed"
}


#setting required paths
setAppDir (){
    SCRIPT_DIR=$(dirname $0)
    SCRIPT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    APP_DIR="`cd "${SCRIPT_HOME}";pwd`"
}

ZIP_TYPE="zip"
COMPOSE_TYPE="compose"
HELM_TYPE="helm"
RPM_TYPE="rpm"
DEB_TYPE="debian"

sourceScript () {
    local file="$1"

    [ ! -z "${file}" ] || errorExit "target file is not passed to source a file"

    if [ ! -f "${file}" ]; then
        errorExit "${file} file is not found"
    else
        source "${file}" || errorExit "Unable to source ${file}, please check if the user ${USER} has permissions to perform this action"
    fi
}
# Source required helpers
initHelpers () {
    local systemYamlHelper="${APP_DIR}/systemYamlHelper.sh"
    local thirdPartyDir=$(find ${APP_DIR}/.. -name third-party -type d)
    export YQ_PATH="${thirdPartyDir}/yq"
    LIBXML2_PATH="${thirdPartyDir}/libxml2/bin/xmllint"
    export LD_LIBRARY_PATH="${thirdPartyDir}/libxml2/lib"
    sourceScript "${systemYamlHelper}"
}
# Check migration info yaml file available in the path
checkMigrationInfoYaml () {

    if [[ -f "${APP_DIR}/migrationHelmInfo.yaml" ]]; then
        MIGRATION_SYSTEM_YAML_INFO="${APP_DIR}/migrationHelmInfo.yaml"
        INSTALLER="${HELM_TYPE}"
    elif [[ -f "${APP_DIR}/migrationZipInfo.yaml" ]]; then
        MIGRATION_SYSTEM_YAML_INFO="${APP_DIR}/migrationZipInfo.yaml"
        INSTALLER="${ZIP_TYPE}"
    elif [[ -f "${APP_DIR}/migrationRpmInfo.yaml" ]]; then
        MIGRATION_SYSTEM_YAML_INFO="${APP_DIR}/migrationRpmInfo.yaml"
        INSTALLER="${RPM_TYPE}"
    elif [[ -f "${APP_DIR}/migrationDebInfo.yaml" ]]; then
        MIGRATION_SYSTEM_YAML_INFO="${APP_DIR}/migrationDebInfo.yaml"
        INSTALLER="${DEB_TYPE}"
    elif [[ -f "${APP_DIR}/migrationComposeInfo.yaml" ]]; then
        MIGRATION_SYSTEM_YAML_INFO="${APP_DIR}/migrationComposeInfo.yaml"
        INSTALLER="${COMPOSE_TYPE}"
    else
        errorExit "File migration Info yaml does not exist in [${APP_DIR}]"
    fi
}

retrieveYamlValue () {
    local yamlPath="$1"
    local value="$2"
    local output="$3"
    local message="$4"

    [[ -z "${yamlPath}" ]] && errorExit "yamlPath is mandatory to get value from ${MIGRATION_SYSTEM_YAML_INFO}"

    getYamlValue "${yamlPath}" "${MIGRATION_SYSTEM_YAML_INFO}" "false"
    value="${YAML_VALUE}"
    if [[ -z "${value}" ]]; then
        if [[ "${output}" == "Warning" ]]; then
            warn "Empty value for ${yamlPath} in [${MIGRATION_SYSTEM_YAML_INFO}]"
        elif [[ "${output}" == "Skip" ]]; then
            return
        else
            errorExit "${message}"
        fi
    fi
}

checkEnv () {
    
    if [[ "${INSTALLER}" == "${ZIP_TYPE}" ]]; then
        # check Environment JF_PRODUCT_HOME is set before migration
        NEW_DATA_DIR="$(evalVariable "NEW_DATA_DIR" "JF_PRODUCT_HOME")"
        if [[ -z "${NEW_DATA_DIR}" ]]; then
            errorExit "Environment variable JF_PRODUCT_HOME is not set, this is required to perform Migration"
        fi
        # appending var directory to $JF_PRODUCT_HOME
        NEW_DATA_DIR="${NEW_DATA_DIR}/var"
    elif [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        getCustomDataDir_hook
        NEW_DATA_DIR="${OLD_DATA_DIR}"
        if [[ -z "${NEW_DATA_DIR}" ]] && [[  -z "${OLD_DATA_DIR}" ]]; then
            errorExit "Could not find ${PROMPT_DATA_DIR_LOCATION} to perform Migration"
        fi
    else
        # check Environment JF_ROOT_DATA_DIR is set before migration
        OLD_DATA_DIR="$(evalVariable "OLD_DATA_DIR" "JF_ROOT_DATA_DIR")"
        # check Environment JF_ROOT_DATA_DIR is set before migration
        NEW_DATA_DIR="$(evalVariable "NEW_DATA_DIR" "JF_ROOT_DATA_DIR")"
        if [[ -z "${NEW_DATA_DIR}" ]] && [[  -z "${OLD_DATA_DIR}" ]]; then
            errorExit "Could not find ${PROMPT_DATA_DIR_LOCATION} to perform Migration"
        fi
            # appending var directory to $JF_PRODUCT_HOME
            NEW_DATA_DIR="${NEW_DATA_DIR}/var"
    fi
    
}

getDataDir () {

    if [[ "${INSTALLER}" == "${ZIP_TYPE}" || "${INSTALLER}" == "${COMPOSE_TYPE}"|| "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        checkEnv
    else
        getCustomDataDir_hook
        NEW_DATA_DIR="`cd "${APP_DIR}"/../../;pwd`"
        NEW_DATA_DIR="${NEW_DATA_DIR}/var"
    fi
}

# Retrieve Product name from MIGRATION_SYSTEM_YAML_INFO
getProduct () {
    retrieveYamlValue "migration.product" "${YAML_VALUE}" "Fail" "Empty value under ${yamlPath} in [${MIGRATION_SYSTEM_YAML_INFO}]"
    PRODUCT="${YAML_VALUE}"
    PRODUCT=$(echo "${PRODUCT}" | tr '[:upper:]' '[:lower:]' 2>/dev/null)
    if [[ "${PRODUCT}" != "artifactory" && "${PRODUCT}" != "distribution" && "${PRODUCT}" != "xray" ]]; then
        errorExit "migration.product in [${MIGRATION_SYSTEM_YAML_INFO}] is not correct, please set based on product as ARTIFACTORY or DISTRIBUTION"
    fi
    if [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        JF_USER="${PRODUCT}"
    fi
}
# Compare product version with minProductVersion and maxProductVersion
migrateCheckVersion () {
    local productVersion="$1"
    local minProductVersion="$2"
    local maxProductVersion="$3"
    local productVersion618="6.18.0"
    local unSupportedProductVersions7=("7.2.0 7.2.1")

    if [[ "$(io_compareVersions "${productVersion}" "${maxProductVersion}")" -eq 0 || "$(io_compareVersions "${productVersion}" "${maxProductVersion}")" -eq 1 ]]; then
        logger "Migration not necessary. ${PRODUCT} is already ${productVersion}"
        exit 11
    elif [[ "$(io_compareVersions "${productVersion}" "${minProductVersion}")" -eq 0 || "$(io_compareVersions "${productVersion}" "${minProductVersion}")" -eq 1 ]]; then
        if [[ ("$(io_compareVersions "${productVersion}" "${productVersion618}")" -eq 0 || "$(io_compareVersions "${productVersion}" "${productVersion618}")" -eq 1) && " ${unSupportedProductVersions7[@]} " =~ " ${CURRENT_VERSION} " ]]; then
            touch /tmp/error;
            errorExit "Current ${PRODUCT} version (${productVersion}) does not support migration to ${CURRENT_VERSION}"
        else
            bannerStart "Detected ${PRODUCT} ${productVersion}, initiating migration"
        fi
    else
        logger "Current ${PRODUCT} ${productVersion} version is not supported for migration"
        exit 1
    fi
}

getProductVersion () {
    local minProductVersion="$1"
    local maxProductVersion="$2"
    local newfilePath="$3"
    local oldfilePath="$4"
    local propertyInDocker="$5"
    local property="$6"
    local productVersion=
    local status=

    if [[ "$INSTALLER" == "${COMPOSE_TYPE}" ]]; then
        if [[ -f "${oldfilePath}" ]]; then
            if [[ "${PRODUCT}" == "artifactory" ]]; then
                productVersion="$(readKey "${property}" "${oldfilePath}")"
            else
                productVersion="$(cat "${oldfilePath}")"
            fi
            status="success"
        elif [[ -f "${newfilePath}" ]]; then
            productVersion="$(readKey "${propertyInDocker}" "${newfilePath}")"
            status="fail"
        else
            logger "File [${oldfilePath}] or [${newfilePath}] not found to get current version."
            exit 0
        fi
    elif [[ "$INSTALLER" == "${HELM_TYPE}" ]]; then
        if [[ -f "${oldfilePath}" ]]; then
            if [[ "${PRODUCT}" == "artifactory" ]]; then
                productVersion="$(readKey "${property}" "${oldfilePath}")"
            else
                productVersion="$(cat "${oldfilePath}")"
            fi
            status="success"
        else
            productVersion="${CURRENT_VERSION}"
            [[ -z "${productVersion}" || "${productVersion}" == "" ]] && logger "${PRODUCT} CURRENT_VERSION is not set" && exit 0
        fi
    else
        if [[ -f "${newfilePath}" ]]; then
            productVersion="$(readKey "${property}" "${newfilePath}")"
            status="fail"
        elif [[ -f "${oldfilePath}" ]]; then
            productVersion="$(readKey "${property}" "${oldfilePath}")"
            status="success"
        else
            if [[ "${INSTALLER}" == "${ZIP_TYPE}" ]]; then
                logger "File [${newfilePath}] not found to get current version."
            else
                logger "File [${oldfilePath}] or [${newfilePath}] not found to get current version."
            fi
            exit 0
        fi
    fi
    if [[ -z "${productVersion}" || "${productVersion}" == "" ]]; then
        [[ "${status}" == "success" ]] && logger "No version found in file [${oldfilePath}]."
        [[ "${status}" == "fail" ]] && logger "No version found in file [${newfilePath}]."
        exit 0
    fi

    migrateCheckVersion "${productVersion}" "${minProductVersion}" "${maxProductVersion}"
}

readKey () {
    local property="$1"
    local file="$2"
    local version=

    while IFS='=' read -r key value || [ -n "${key}" ];
    do
        [[ ! "${key}" =~ \#.* && ! -z "${key}" && ! -z "${value}" ]]
        key="$(io_trim "${key}")"
        if [[ "${key}" == "${property}" ]]; then
            version="${value}" && check=true && break
        else
            check=false
        fi
    done < "${file}"
    if [[ "${check}" == "false" ]]; then
        return
    fi
    echo "${version}"
}

# create Log directory
createLogDir () {
    if [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        getUserAndGroupFromFile
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/log" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}"
    fi
}

# Creating migration log file
creationMigrateLog () {
    local LOG_FILE_NAME="migration.log"
    createLogDir
    local MIGRATION_LOG_FILE="${NEW_DATA_DIR}/log/${LOG_FILE_NAME}"
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        MIGRATION_LOG_FILE="${SCRIPT_HOME}/${LOG_FILE_NAME}"
    fi
    touch "${MIGRATION_LOG_FILE}"
    setFilePermission "${LOG_FILE_PERMISSION}" "${MIGRATION_LOG_FILE}"
    exec &> >(tee -a "${MIGRATION_LOG_FILE}")   
}
# Set path where system.yaml should create
setSystemYamlPath () {
    SYSTEM_YAML_PATH="${NEW_DATA_DIR}/etc/system.yaml"
    if [[ "${INSTALLER}" != "${HELM_TYPE}" ]]; then
        logger "system.yaml will be created in path [${SYSTEM_YAML_PATH}]"
    fi
}
# Create directory
createDirectory () {
    local directory="$1"
    local output="$2"
    local check=false
    local message="Could not create directory ${directory}, please check if the user ${USER} has permissions to perform this action"
    removeSoftLink "${directory}"
    mkdir -p "${directory}" && check=true || check=false
    if [[ "${check}" == "false" ]]; then
        if [[ "${output}" == "Warning" ]]; then
            warn "${message}"
        else
            errorExit "${message}"
        fi
    fi
    setOwnershipBasedOnInstaller "${directory}"
}

setOwnershipBasedOnInstaller () {
    local directory="$1"
    if [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        getUserAndGroupFromFile
        chown -R ${USER_TO_CHECK}:${GROUP_TO_CHECK} "${directory}" || warn "Setting ownership on $directory failed"
    elif [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        io_setOwnership "${directory}" "${JF_USER}" "${JF_USER}"
    fi
}

getUserAndGroup () {
    local file="$1"
    read uid gid <<<$(stat -c '%U %G' ${file})
    USER_TO_CHECK="${uid}"
    GROUP_TO_CHECK="${gid}"
}
    
# set ownership
getUserAndGroupFromFile () {
    case $PRODUCT in
        artifactory)
            getUserAndGroup "/etc/opt/jfrog/artifactory/artifactory.properties"
        ;;
        distribution)
            getUserAndGroup "${OLD_DATA_DIR}/etc/versions.properties"
        ;;
        xray)
            getUserAndGroup "${OLD_DATA_DIR}/security/master.key"
        ;;
        esac
} 

# creating required directories
createRequiredDirs () {
    bannerSubSection "CREATING REQUIRED DIRECTORIES"
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}"  ]]; then
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/etc/security" "${JF_USER}" "${JF_USER}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/data" "${JF_USER}" "${JF_USER}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/log/archived" "${JF_USER}" "${JF_USER}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/work" "${JF_USER}" "${JF_USER}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/backup" "${JF_USER}" "${JF_USER}" "yes"
        io_setOwnership "${NEW_DATA_DIR}" "${JF_USER}" "${JF_USER}"
        if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" ]]; then
            removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/data/postgres" "${POSTGRES_USER}" "${POSTGRES_USER}" "yes"
        fi
    elif [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        getUserAndGroupFromFile
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/etc" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/etc/security" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/data" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/log/archived" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/work" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
        removeSoftLinkAndCreateDir "${NEW_DATA_DIR}/backup" "${USER_TO_CHECK}" "${GROUP_TO_CHECK}" "yes"
    fi
}

# Check entry in map is format
checkMapEntry () {
    local entry="$1"

    [[ "${entry}" != *"="* ]] && echo -n "false" || echo -n "true"
}
# Check value Empty and warn
warnIfEmpty () {
    local filePath="$1"
    local yamlPath="$2"
    local check=

    if [[ -z "${filePath}" ]]; then
        warn "Empty value in yamlpath [${yamlPath} in [${MIGRATION_SYSTEM_YAML_INFO}]"
        check=false
    else
        check=true
    fi
    echo "${check}"
}

logCopyStatus () {
    local status="$1"
    local logMessage="$2"
    local warnMessage="$3"

    [[ "${status}" == "success"  ]] && logger "${logMessage}"
    [[ "${status}" == "fail" ]] && warn "${warnMessage}"
}
# copy contents from source to destination
copyCmd () {
    local source="$1"
    local target="$2"
    local mode="$3"
    local status=
    
    case $mode in
        unique)
            cp -up "${source}"/* "${target}"/ && status="success" || status="fail"
            logCopyStatus "${status}" "Successfully copied directory contents from [${source}] to [${target}]" "Failed to copy directory contents from [${source}] to [${target}]"
        ;;
        specific)
            cp -pf "${source}" "${target}"/ && status="success" || status="fail"
            logCopyStatus "${status}" "Successfully copied file [${source}] to [${target}]" "Failed to copy file [${source}] to [${target}]"
        ;;
        patternFiles)
            cp -pf "${source}"* "${target}"/ && status="success" || status="fail"
            logCopyStatus "${status}" "Successfully copied files matching [${source}*] to [${target}]" "Failed to copy files matching [${source}*] to [${target}]"
        ;;
        full)
            cp -prf "${source}"/* "${target}"/ && status="success" || status="fail"
            logCopyStatus "${status}" "Successfully copied directory contents from [${source}] to [${target}]" "Failed to copy directory contents from [${source}] to [${target}]"
        ;;
    esac
}
# Check contents exist in source before copying
copyOnContentExist () {
    local source="$1"
    local target="$2"
    local mode="$3"

    if [[ "$(checkContentExists "${source}")" == "true" ]]; then
        copyCmd "${source}" "${target}" "${mode}"
    else
        logger "No contents to copy from [${source}]"
    fi
}

# move source to destination
moveCmd () {
    local source="$1"
    local target="$2"
    local status=
    
    mv -f "${source}" "${target}" && status="success" || status="fail"
    [[ "${status}" == "success" ]] && logger "Successfully moved directory [${source}] to [${target}]"
    [[ "${status}" == "fail" ]] && warn "Failed to move directory [${source}] to [${target}]"
}

# symlink target to source
symlinkCmd () {
    local source="$1"
    local target="$2"
    local symlinkSubDir="$3"
    local check=false
    
    if [[ "${symlinkSubDir}" == "subDir" ]]; then
        ln -sf "${source}"/* "${target}" && check=true || check=false
    else
        ln -sf "${source}" "${target}"   && check=true || check=false
    fi
    
    [[ "${check}" == "true"  ]] && logger "Successfully symlinked directory [${target}] to old [${source}]"
    [[ "${check}" == "false" ]] && warn "Symlink operation failed"
}
# Check contents exist in source before symlinking
symlinkOnExist () {
    local source="$1"
    local target="$2"
    local symlinkSubDir="$3"

    if [[ "$(checkContentExists "${source}")" == "true" ]]; then
        if [[ "${symlinkSubDir}" == "subDir" ]]; then
            symlinkCmd "${source}" "${target}" "subDir"
        else
            symlinkCmd "${source}" "${target}"
        fi
    else
        logger "No contents to symlink from [${source}]"
    fi
}

prependDir () {
    local absolutePath="$1"
    local fullPath="$2"
    local sourcePath=

    if [[ "${absolutePath}" = \/* ]]; then
        sourcePath="${absolutePath}"
    else
        sourcePath="${fullPath}"
    fi
    echo "${sourcePath}"
}

getFirstEntry (){
    local entry="$1"

    [[ -z "${entry}" ]] && return
    echo "${entry}" | awk -F"=" '{print $1}'
}

getSecondEntry () {
    local entry="$1"

    [[ -z "${entry}" ]] && return
    echo "${entry}" | awk -F"=" '{print $2}'
}
# To get absolutePath
pathResolver () {
    local directoryPath="$1"
    local dataDir=

    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" ||  "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        retrieveYamlValue "migration.oldDataDir" "oldDataDir" "Warning"
        dataDir="${YAML_VALUE}"
        cd "${dataDir}"
    else
        cd "${OLD_DATA_DIR}"
    fi
    absoluteDir="`cd "${directoryPath}";pwd`"
    echo "${absoluteDir}"
}

checkPathResolver () {
    local value="$1"

    if [[ "${value}" == \/* ]]; then
        value="${value}"
    else
        value="$(pathResolver "${value}")"
    fi
    echo "${value}"
}

propertyMigrate () {
    local entry="$1"
    local filePath="$2"
    local fileName="$3"
    local check=false

    local yamlPath="$(getFirstEntry "${entry}")"
    local property="$(getSecondEntry "${entry}")"
    if [[ -z "${property}" ]]; then
        warn "Property is empty in map [${entry}] in the file [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    if [[ -z "${yamlPath}" ]]; then
        warn "yamlPath is empty for [${property}] in [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    while IFS='=' read -r key value || [ -n "${key}" ];
    do
        [[ ! "${key}" =~ \#.* && ! -z "${key}" && ! -z "${value}" ]]
        key="$(io_trim "${key}")"
        if [[ "${key}" == "${property}" ]]; then
            if [[ "${PRODUCT}" == "artifactory" ]]; then
                value="$(migrateResolveDerbyPath "${key}" "${value}")"
                value="$(migrateResolveHaDirPath "${key}" "${value}")"
                value="$(updatePostgresUrlString_Hook "${yamlPath}" "${value}")"
            fi
            if [[ "${key}" == "context.url" ]]; then
                local ip=$(echo "${value}" | awk -F/ '{print $3}' | sed 's/:.*//')
                setSystemValue "shared.node.ip" "${ip}" "${SYSTEM_YAML_PATH}"
                logger "Setting [shared.node.ip] with [${ip}] in system.yaml"
            fi
            setSystemValue "${yamlPath}" "${value}" "${SYSTEM_YAML_PATH}" && logger "Setting [${yamlPath}] with value of the property [${property}] in system.yaml" && check=true && break || check=false
        fi
    done < "${NEW_DATA_DIR}/${filePath}/${fileName}"
    [[ "${check}" == "false" ]] && logger "Property [${property}] not found in file [${fileName}]"
}

setHaEnabled_hook () {
    echo ""
}

migratePropertiesFiles () {
    local fileList=
    local filePath=
    local fileName=
    local map=
    
    retrieveYamlValue "migration.propertyFiles.files" "fileList" "Skip"
    fileList="${YAML_VALUE}"
    if [[ -z "${fileList}" ]]; then
        return
    fi
    bannerSection "PROCESSING MIGRATION OF PROPERTY FILES"
    for file in ${fileList};
    do
        bannerSubSection "Processing Migration of $file"
        retrieveYamlValue "migration.propertyFiles.$file.filePath" "filePath" "Warning"
        filePath="${YAML_VALUE}"
        retrieveYamlValue "migration.propertyFiles.$file.fileName" "fileName" "Warning"
        fileName="${YAML_VALUE}"
        [[ -z "${filePath}" && -z "${fileName}" ]] && continue
        if [[ "$(checkFileExists "${NEW_DATA_DIR}/${filePath}/${fileName}")" == "true" ]]; then
            logger "File [${fileName}] found in path [${NEW_DATA_DIR}/${filePath}]"
            # setting haEnabled with true only if ha-node.properties is present
            setHaEnabled_hook "${filePath}"
            retrieveYamlValue "migration.propertyFiles.$file.map" "map" "Warning"
            map="${YAML_VALUE}"
            [[ -z "${map}" ]] && continue
            for entry in $map;
            do
                if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
                    propertyMigrate "${entry}" "${filePath}" "${fileName}"
                else
                    warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e yamlPath=property"
                fi
            done
        else
            logger "File [${fileName}] was not found in path [${NEW_DATA_DIR}/${filePath}] to migrate"
        fi
    done
}

createTargetDir () {
    local mountDir="$1"
    local target="$2"

    logger "Target directory not found [${mountDir}/${target}], creating it"
    createDirectoryRecursive "${mountDir}" "${target}" "Warning"
}

createDirectoryRecursive () {
    local mountDir="$1"
    local target="$2"
    local output="$3"
    local check=false
    local message="Could not create directory ${directory}, please check if the user ${USER} has permissions to perform this action"
    removeSoftLink "${mountDir}/${target}"
    local directory=$(echo "${target}" | tr '/' ' ' )
    local targetDir="${mountDir}"
    for dir in ${directory}; 
    do
        targetDir="${targetDir}/${dir}"
        mkdir -p "${targetDir}" && check=true || check=false
        setOwnershipBasedOnInstaller "${targetDir}"
    done
    if [[ "${check}" == "false" ]]; then
        if [[ "${output}" == "Warning" ]]; then
            warn "${message}"
        else
            errorExit "${message}"
        fi
    fi
}

copyOperation () {
    local source="$1"
    local target="$2"
    local mode="$3"
    local check=false
    local targetDataDir=
    local targetLink=
    local date=

    # prepend OLD_DATA_DIR only if source is relative path
    source="$(prependDir "${source}" "${OLD_DATA_DIR}/${source}")"
    if [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        targetDataDir="${NEW_DATA_DIR}"
    else
        targetDataDir="`cd "${NEW_DATA_DIR}"/../;pwd`"
    fi
    copyLogMessage "${mode}"
    #remove source if it is a symlink
    if [[ -L "${source}" ]]; then
        targetLink=$(readlink -f "${source}")
        logger "Removing the symlink [${source}] pointing to [${targetLink}]"
        rm -f "${source}"
        source=${targetLink}
    fi
    if [[ "$(checkDirExists "${source}")" != "true" ]]; then
        logger "Source [${source}] directory not found in path"
        return
    fi
    if [[ "$(checkDirContents "${source}")" != "true" ]]; then
        logger "No contents to copy from [${source}]"
        return
    fi
    if [[ "$(checkDirExists "${targetDataDir}/${target}")" != "true" ]]; then
        createTargetDir "${targetDataDir}" "${target}"
    fi
    copyOnContentExist "${source}" "${targetDataDir}/${target}" "${mode}"
}

copySpecificFiles () {
    local source="$1"
    local target="$2"
    local mode="$3"
    
    # prepend OLD_DATA_DIR only if source is relative path
    source="$(prependDir "${source}" "${OLD_DATA_DIR}/${source}")"
    if [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        targetDataDir="${NEW_DATA_DIR}"
    else
        targetDataDir="`cd "${NEW_DATA_DIR}"/../;pwd`"
    fi
    copyLogMessage "${mode}"
    if [[ "$(checkFileExists "${source}")" != "true" ]]; then
        logger "Source file [${source}] does not exist in path"
        return
    fi
    if [[ "$(checkDirExists "${targetDataDir}/${target}")" != "true" ]]; then
        createTargetDir "${targetDataDir}" "${target}"
    fi
    copyCmd "${source}" "${targetDataDir}/${target}" "${mode}"
}

copyPatternMatchingFiles () {
    local source="$1"
    local target="$2"
    local mode="$3"
    local sourcePath="${4}"

    # prepend OLD_DATA_DIR only if source is relative path
    sourcePath="$(prependDir "${sourcePath}" "${OLD_DATA_DIR}/${sourcePath}")"
    if [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        targetDataDir="${NEW_DATA_DIR}"
    else
        targetDataDir="`cd "${NEW_DATA_DIR}"/../;pwd`"
    fi
    copyLogMessage "${mode}"
    if [[ "$(checkDirExists "${sourcePath}")" != "true" ]]; then
        logger "Source [${sourcePath}] directory not found in path"
        return
    fi
    if ls "${sourcePath}/${source}"* 1> /dev/null 2>&1; then
        if [[ "$(checkDirExists "${targetDataDir}/${target}")" != "true" ]]; then
            createTargetDir "${targetDataDir}" "${target}"
        fi
        copyCmd "${sourcePath}/${source}" "${targetDataDir}/${target}" "${mode}"
    else
        logger "Source file [${sourcePath}/${source}*] does not exist in path"
    fi
}

copyLogMessage () {
    local mode="$1"
    case $mode in
        specific)
            logger "Copy file [${source}] to target [${targetDataDir}/${target}]"
        ;;
        patternFiles)
            logger "Copy files matching [${sourcePath}/${source}*] to target [${targetDataDir}/${target}]"
        ;;
        full)
            logger "Copy directory contents from source [${source}] to target [${targetDataDir}/${target}]"
        ;;
        unique)
            logger "Copy directory contents from source [${source}] to target [${targetDataDir}/${target}]"
        ;;
    esac
}

copyBannerMessages () {
    local mode="$1"
    local textMode="$2"
    case $mode in
        specific)
            bannerSection "COPY ${textMode} FILES"
        ;;
        patternFiles)
            bannerSection "COPY MATCHING ${textMode}"
        ;;
        full)
            bannerSection "COPY ${textMode} DIRECTORIES CONTENTS"
        ;;
        unique)
            bannerSection "COPY ${textMode} DIRECTORIES CONTENTS"
        ;;
    esac
}

invokeCopyFunctions () {
    local mode="$1"
    local source="$2"
    local target="$3"

    case $mode in
        specific)
            copySpecificFiles "${source}" "${target}" "${mode}"
        ;;
        patternFiles)
            retrieveYamlValue "migration.${copyFormat}.sourcePath" "map" "Warning"
            local sourcePath="${YAML_VALUE}"
            copyPatternMatchingFiles "${source}" "${target}" "${mode}" "${sourcePath}"
        ;;
        full)
            copyOperation "${source}" "${target}" "${mode}"
        ;;
        unique)
            copyOperation "${source}" "${target}" "${mode}"
        ;;
    esac
}
# Copies contents from source directory and target directory
copyDataDirectories () {
    local copyFormat="$1"
    local mode="$2"
    local map=
    local source=
    local target=
    local textMode=
    local targetDataDir=
    local copyFormatValue=

    retrieveYamlValue "migration.${copyFormat}" "${copyFormat}" "Skip"
    copyFormatValue="${YAML_VALUE}"
    if [[ -z "${copyFormatValue}" ]]; then
        return
    fi
    textMode=$(echo "${mode}" | tr '[:lower:]' '[:upper:]' 2>/dev/null)
    copyBannerMessages "${mode}" "${textMode}"
    retrieveYamlValue "migration.${copyFormat}.map" "map" "Warning"
    map="${YAML_VALUE}"
    if [[ "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        targetDataDir="${NEW_DATA_DIR}"
    else
        targetDataDir="`cd "${NEW_DATA_DIR}"/../;pwd`"
    fi
    for entry in $map;
    do
        if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
            source="$(getSecondEntry "${entry}")"
            target="$(getFirstEntry "${entry}")"
            [[ -z "${source}" ]] && warn "source value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            [[ -z "${target}" ]] && warn "target value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            invokeCopyFunctions "${mode}" "${source}" "${target}"
        else
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e target=source"
        fi
        echo "";
    done
}

invokeMoveFunctions () {
    local source="$1"
    local target="$2"
    local sourceDataDir=
    local targetBasename=
    # prepend OLD_DATA_DIR only if source is relative path
    sourceDataDir=$(prependDir "${source}" "${OLD_DATA_DIR}/${source}")
    targetBasename=$(dirname "${target}")
    logger "Moving directory source [${sourceDataDir}] to target [${NEW_DATA_DIR}/${target}]"
    if [[ "$(checkDirExists "${sourceDataDir}")" != "true" ]]; then
        logger "Directory [${sourceDataDir}] not found in path to move"
        return
    fi
    if [[ "$(checkDirExists "${NEW_DATA_DIR}/${targetBasename}")" != "true" ]]; then
        createTargetDir "${NEW_DATA_DIR}" "${targetBasename}"
        moveCmd "${sourceDataDir}" "${NEW_DATA_DIR}/${target}"
    else
        moveCmd "${sourceDataDir}" "${NEW_DATA_DIR}/tempDir"
        moveCmd "${NEW_DATA_DIR}/tempDir" "${NEW_DATA_DIR}/${target}"
    fi
}

# Move source directory and target directory
moveDirectories () {
    local moveDataDirectories=
    local map=
    local source=
    local target=

    retrieveYamlValue "migration.moveDirectories" "moveDirectories" "Skip"
    moveDirectories="${YAML_VALUE}"
    if [[ -z "${moveDirectories}" ]]; then
        return
    fi
    bannerSection "MOVE DIRECTORIES"
    retrieveYamlValue "migration.moveDirectories.map" "map" "Warning"
    map="${YAML_VALUE}"
    for entry in $map;
    do
        if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
            source="$(getSecondEntry "${entry}")"
            target="$(getFirstEntry "${entry}")"
            [[ -z "${source}" ]] && warn "source value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            [[ -z "${target}" ]] && warn "target value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            invokeMoveFunctions "${source}" "${target}"
        else
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e target=source"
        fi
    echo "";
    done
}

# Trim masterKey if its generated using hex 32 
trimMasterKey () {
    local masterKeyDir=/opt/jfrog/artifactory/var/etc/security
    local oldMasterKey=$(<${masterKeyDir}/master.key)
    local oldMasterKey_Length=$(echo ${#oldMasterKey})
    local newMasterKey=
    if [[ ${oldMasterKey_Length} -gt 32 ]]; then
        bannerSection "TRIM MASTERKEY"
        newMasterKey=$(echo ${oldMasterKey:0:32})
        cp ${masterKeyDir}/master.key ${masterKeyDir}/backup_master.key
        logger "Original masterKey is backed up : ${masterKeyDir}/backup_master.key"
        rm -rf ${masterKeyDir}/master.key
        echo ${newMasterKey} > ${masterKeyDir}/master.key
        logger "masterKey is trimmed : ${masterKeyDir}/master.key"
    fi
}

copyDirectories () {

    copyDataDirectories "copyFiles" "full"
    copyDataDirectories "copyUniqueFiles" "unique"
    copyDataDirectories "copySpecificFiles" "specific"
    copyDataDirectories "copyPatternMatchingFiles" "patternFiles"
}

symlinkDir () {
    local source="$1"
    local target="$2"
    local targetDir=
    local basename=
    local targetParentDir=
    
    targetDir="$(dirname "${target}")"
    if [[ "${targetDir}" == "${source}" ]]; then
        # symlink the sub directories
        createDirectory "${NEW_DATA_DIR}/${target}" "Warning"
        if [[ "$(checkDirExists "${NEW_DATA_DIR}/${target}")" == "true" ]]; then
            symlinkOnExist "${OLD_DATA_DIR}/${source}" "${NEW_DATA_DIR}/${target}" "subDir"
            basename="$(basename "${target}")"
            cd "${NEW_DATA_DIR}/${target}" && rm -f "${basename}"
        fi
    else
        targetParentDir="$(dirname "${NEW_DATA_DIR}/${target}")"
        createDirectory "${targetParentDir}" "Warning"
        if [[ "$(checkDirExists "${targetParentDir}")" == "true" ]]; then
            symlinkOnExist "${OLD_DATA_DIR}/${source}" "${NEW_DATA_DIR}/${target}"
        fi
    fi
}

symlinkOperation () {
    local source="$1"
    local target="$2"
    local check=false
    local targetLink=
    local date=
    
    #   Check if source is a link and do symlink
    if [[ -L "${OLD_DATA_DIR}/${source}" ]]; then
        targetLink=$(readlink -f "${OLD_DATA_DIR}/${source}")
        symlinkOnExist "${targetLink}" "${NEW_DATA_DIR}/${target}"
    else
        #  check if source is directory and do symlink
        if [[ "$(checkDirExists "${OLD_DATA_DIR}/${source}")" != "true" ]]; then
            logger "Source [${source}] directory not found in path to symlink"
            return
        fi
        if [[ "$(checkDirContents "${OLD_DATA_DIR}/${source}")" != "true" ]]; then
            logger "No contents found in [${OLD_DATA_DIR}/${source}] to symlink"
            return
        fi
        if [[ "$(checkDirExists "${NEW_DATA_DIR}/${target}")" != "true" ]]; then
            logger "Target directory [${NEW_DATA_DIR}/${target}] does not exist to create symlink, creating it"
            symlinkDir "${source}" "${target}"
        else
            rm -rf "${NEW_DATA_DIR}/${target}" && check=true || check=false
            [[ "${check}" == "false" ]] && warn "Failed to remove contents in [${NEW_DATA_DIR}/${target}/]"
            symlinkDir "${source}" "${target}"
        fi
    fi
}
# Creates a symlink path - Source directory to which the symbolic link should point.
symlinkDirectories () {
    local linkFiles=
    local map=
    local source=
    local target=

    retrieveYamlValue "migration.linkFiles" "linkFiles" "Skip"
    linkFiles="${YAML_VALUE}"
    if [[ -z "${linkFiles}" ]]; then
        return
    fi
    bannerSection "SYMLINK DIRECTORIES"
    retrieveYamlValue "migration.linkFiles.map" "map" "Warning"
    map="${YAML_VALUE}"
    for entry in $map;
    do
        if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
            source="$(getSecondEntry "${entry}")"
            target="$(getFirstEntry "${entry}")"
            logger "Symlink directory [${NEW_DATA_DIR}/${target}] to old [${OLD_DATA_DIR}/${source}]"
            [[ -z "${source}" ]] && warn "source value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            [[ -z "${target}" ]] && warn "target value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
            symlinkOperation "${source}" "${target}"
        else
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e target=source"
        fi
        echo "";
    done
}

updateConnectionString () {
    local yamlPath="$1"
    local value="$2"
    local mongoPath="shared.mongo.url"
    local rabbitmqPath="shared.rabbitMq.url"
    local postgresPath="shared.database.url"
    local redisPath="shared.redis.connectionString"
    local mongoConnectionString="mongo.connectionString"
    local sourceKey=
    local hostIp=$(io_getPublicHostIP)
    local hostKey=
    
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then 
    # Replace @postgres:,@mongodb:,@rabbitmq:,@redis: to @{hostIp}: (Compose Installer)
        hostKey="@${hostIp}:"
        case $yamlPath in
            ${postgresPath})
                sourceKey="@postgres:"
                value=$(io_replaceString "${value}" "${sourceKey}" "${hostKey}")
            ;;
            ${mongoPath})
                sourceKey="@mongodb:"
                value=$(io_replaceString "${value}" "${sourceKey}" "${hostKey}")
            ;;
            ${rabbitmqPath})
                sourceKey="@rabbitmq:"
                value=$(io_replaceString "${value}" "${sourceKey}" "${hostKey}")
            ;;
            ${redisPath})
                sourceKey="@redis:"
                value=$(io_replaceString "${value}" "${sourceKey}" "${hostKey}")
            ;;
            ${mongoConnectionString})
                sourceKey="@mongodb:"
                value=$(io_replaceString "${value}" "${sourceKey}" "${hostKey}")
            ;;
        esac
    fi
    echo -n "${value}"
}

yamlMigrate () {
    local entry="$1"
    local sourceFile="$2"
    local value=
    local yamlPath=
    local key=
    yamlPath="$(getFirstEntry "${entry}")"
    key="$(getSecondEntry "${entry}")"
    if [[ -z "${key}" ]]; then
        warn "key is empty in map [${entry}] in the file [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    if [[ -z "${yamlPath}" ]]; then
        warn "yamlPath is empty for [${key}] in [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    getYamlValue "${key}" "${sourceFile}" "false"
    value="${YAML_VALUE}"
    if [[ ! -z "${value}" ]]; then
        value=$(updateConnectionString "${yamlPath}" "${value}")
    fi
    if [[ "${PRODUCT}" == "artifactory" ]]; then
        replicatorProfiling
    fi
    if [[ -z "${value}" ]]; then
        logger "No value for [${key}] in [${sourceFile}]"
    else
        setSystemValue "${yamlPath}" "${value}" "${SYSTEM_YAML_PATH}"
        logger "Setting [${yamlPath}] with value of the key [${key}] in system.yaml"
    fi
}

migrateYamlFile () {
    local files=
    local filePath=
    local fileName=
    local sourceFile=
    local map=
    retrieveYamlValue "migration.yaml.files" "files" "Skip"
    files="${YAML_VALUE}"
    if [[ -z "${files}" ]]; then
        return
    fi
    bannerSection "MIGRATION OF YAML FILES"
    for file in $files;
    do
        bannerSubSection "Processing Migration of $file"
        retrieveYamlValue "migration.yaml.$file.filePath" "filePath" "Warning"
        filePath="${YAML_VALUE}"
        retrieveYamlValue "migration.yaml.$file.fileName" "fileName" "Warning"
        fileName="${YAML_VALUE}"
        [[ -z "${filePath}" && -z "${fileName}" ]] && continue
        sourceFile="${NEW_DATA_DIR}/${filePath}/${fileName}"
        if [[ "$(checkFileExists "${sourceFile}")" == "true" ]]; then
            logger "File [${fileName}] found in path [${NEW_DATA_DIR}/${filePath}]"
            retrieveYamlValue "migration.yaml.$file.map" "map" "Warning"
            map="${YAML_VALUE}"
            [[ -z "${map}" ]] && continue
            for entry in $map;
            do
                if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
                    yamlMigrate "${entry}" "${sourceFile}"
                else
                    warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e yamlPath=key"
                fi
            done
        else
            logger "File [${fileName}] is not found in path [${NEW_DATA_DIR}/${filePath}] to migrate"
        fi
    done
}
# updates the key and value in system.yaml
updateYamlKeyValue () {
    local entry="$1"
    local value=
    local yamlPath=
    local key=

    yamlPath="$(getFirstEntry "${entry}")"
    value="$(getSecondEntry "${entry}")"
    if [[ -z "${value}" ]]; then
        warn "value is empty in map [${entry}] in the file [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    if [[ -z "${yamlPath}" ]]; then
        warn "yamlPath is empty for [${key}] in [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    setSystemValue "${yamlPath}" "${value}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${yamlPath}] with value [${value}] in system.yaml"
}

updateSystemYamlFile () {
    local updateYaml=
    local map=

    retrieveYamlValue "migration.updateSystemYaml" "updateYaml" "Skip"
    updateSystemYaml="${YAML_VALUE}"
    if [[ -z "${updateSystemYaml}" ]]; then
        return
    fi
    bannerSection "UPDATE SYSTEM YAML FILE WITH KEY AND VALUES"
    retrieveYamlValue "migration.updateSystemYaml.map" "map" "Warning"
    map="${YAML_VALUE}"
    if [[ -z "${map}" ]]; then
        return
    fi
    for entry in $map;
    do
        if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
            updateYamlKeyValue "${entry}"
        else
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e yamlPath=key"
        fi
    done
}

backupFiles_hook () {
    logSilly "Method ${FUNCNAME[0]}"
}

backupDirectory () {
    local backupDir="$1"
    local dir="$2"
    local targetDir="$3"
    local effectiveUser=
    local effectiveGroup=

    if [[ "${dir}" = \/* ]]; then
        dir=$(echo "${dir/\//}")
    fi
            
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then 
        effectiveUser="${JF_USER}"
        effectiveGroup="${JF_USER}"
    elif [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        effectiveUser="${USER_TO_CHECK}" 
        effectiveGroup="${GROUP_TO_CHECK}"
    fi
    
    removeSoftLinkAndCreateDir "${backupDir}" "${effectiveUser}" "${effectiveGroup}" "yes"
    local backupDirectory="${backupDir}/${PRODUCT}"
    removeSoftLinkAndCreateDir "${backupDirectory}" "${effectiveUser}" "${effectiveGroup}" "yes"
    removeSoftLinkAndCreateDir "${backupDirectory}/${dir}" "${effectiveUser}" "${effectiveGroup}" "yes"
    local outputCheckDirExists="$(checkDirExists "${backupDirectory}/${dir}")"
    if [[ "${outputCheckDirExists}" == "true" ]]; then
        copyOnContentExist "${targetDir}" "${backupDirectory}/${dir}" "full"
    fi
}

removeOldDirectory () {
    local backupDir="$1"
    local entry="$2"
    local check=false
    
    # prepend OLD_DATA_DIR only if entry is relative path
    local targetDir="$(prependDir "${entry}" "${OLD_DATA_DIR}/${entry}")"
    local outputCheckDirExists="$(checkDirExists "${targetDir}")"
    if [[ "${outputCheckDirExists}" != "true" ]]; then
        logger "No [${targetDir}] directory found to delete"
        echo "";
        return
    fi
    backupDirectory "${backupDir}" "${entry}" "${targetDir}"
    rm -rf  "${targetDir}" && check=true || check=false
    [[ "${check}" == "true"  ]] && logger "Successfully removed directory [${targetDir}]"
    [[ "${check}" == "false" ]] && warn "Failed to remove directory [${targetDir}]"
    echo "";
}

cleanUpOldDataDirectories () {
    local cleanUpOldDataDir=
    local map=
    local entry=

    retrieveYamlValue "migration.cleanUpOldDataDir" "cleanUpOldDataDir" "Skip"
    cleanUpOldDataDir="${YAML_VALUE}"
    if [[ -z "${cleanUpOldDataDir}" ]]; then
        return
    fi
    bannerSection "CLEAN UP OLD DATA DIRECTORIES"
    retrieveYamlValue "migration.cleanUpOldDataDir.map" "map" "Warning"
    map="${YAML_VALUE}"
    [[ -z "${map}" ]] && continue
    date="$(date +%Y%m%d%H%M)"
    backupDir="${NEW_DATA_DIR}/backup/backup-${date}"
    bannerImportant "****** Old data configurations are backedup in [${backupDir}] directory ******"
    backupFiles_hook "${backupDir}/${PRODUCT}"
    for entry in $map;
    do
        removeOldDirectory "${backupDir}" "${entry}"
    done
}

backupFiles () {
    local backupDir="$1"
    local dir="$2"
    local targetDir="$3"
    local fileName="$4"
    local effectiveUser=
    local effectiveGroup=

    if [[ "${dir}" = \/* ]]; then
        dir=$(echo "${dir/\//}")
    fi
            
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then 
        effectiveUser="${JF_USER}"
        effectiveGroup="${JF_USER}"
    elif [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        effectiveUser="${USER_TO_CHECK}" 
        effectiveGroup="${GROUP_TO_CHECK}"
    fi

    removeSoftLinkAndCreateDir "${backupDir}" "${effectiveUser}" "${effectiveGroup}" "yes"
    local backupDirectory="${backupDir}/${PRODUCT}"
    removeSoftLinkAndCreateDir "${backupDirectory}" "${effectiveUser}" "${effectiveGroup}" "yes"
    removeSoftLinkAndCreateDir "${backupDirectory}/${dir}" "${effectiveUser}" "${effectiveGroup}" "yes"
    local outputCheckDirExists="$(checkDirExists "${backupDirectory}/${dir}")"
    if [[ "${outputCheckDirExists}" == "true" ]]; then
        copyCmd "${targetDir}/${fileName}" "${backupDirectory}/${dir}" "specific"
    fi
}

removeOldFiles () {
    local backupDir="$1"
    local directoryName="$2"
    local fileName="$3"
    local check=false
    
    # prepend OLD_DATA_DIR only if entry is relative path
    local targetDir="$(prependDir "${directoryName}" "${OLD_DATA_DIR}/${directoryName}")"
    local outputCheckFileExists="$(checkFileExists "${targetDir}/${fileName}")"
    if [[ "${outputCheckFileExists}" != "true" ]]; then
        logger "No [${targetDir}/${fileName}] file found to delete"
        return
    fi
    backupFiles "${backupDir}" "${directoryName}" "${targetDir}" "${fileName}"
    rm -f  "${targetDir}/${fileName}" && check=true || check=false
    [[ "${check}" == "true"  ]] && logger "Successfully removed file [${targetDir}/${fileName}]"
    [[ "${check}" == "false" ]] && warn "Failed to remove file [${targetDir}/${fileName}]"
    echo "";
}

cleanUpOldFiles () {
    local cleanUpFiles=
    local map=
    local entry=

    retrieveYamlValue "migration.cleanUpOldFiles" "cleanUpOldFiles" "Skip"
    cleanUpOldFiles="${YAML_VALUE}"
    if [[ -z "${cleanUpOldFiles}" ]]; then
        return
    fi
    bannerSection "CLEAN UP OLD FILES"
    retrieveYamlValue "migration.cleanUpOldFiles.map" "map" "Warning"
    map="${YAML_VALUE}"
    [[ -z "${map}" ]] && continue
    date="$(date +%Y%m%d%H%M)"
    backupDir="${NEW_DATA_DIR}/backup/backup-${date}"
    bannerImportant "****** Old files are backedup in [${backupDir}] directory ******"
    for entry in $map;
    do  
        local outputCheckMapEntry="$(checkMapEntry "${entry}")"
        if [[ "${outputCheckMapEntry}" != "true" ]]; then
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e directoryName=fileName"
        fi
        local fileName="$(getSecondEntry "${entry}")"
        local directoryName="$(getFirstEntry "${entry}")"
        [[ -z "${fileName}" ]] && warn "File name value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
        [[ -z "${directoryName}" ]] && warn "Directory name value is empty for [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}]" && continue
        removeOldFiles "${backupDir}" "${directoryName}" "${fileName}"
        echo "";
    done 
}

startMigration () {
    bannerSection "STARTING MIGRATION"
}

endMigration () {
    bannerSection "MIGRATION COMPLETED SUCCESSFULLY"
}

initialize () {
    setAppDir
    _pauseExecution "setAppDir"
    initHelpers
    _pauseExecution "initHelpers"
    checkMigrationInfoYaml
    _pauseExecution "checkMigrationInfoYaml"
    getProduct
    _pauseExecution "getProduct"
    getDataDir
    _pauseExecution "getDataDir"
}

main () {
    case $PRODUCT in
        artifactory)
            migrateArtifactory
        ;;
        distribution)
            migrateDistribution
        ;;
        xray)
            migrationXray
        ;;
    esac
    exit 0
}

# Ensures meta data is logged
LOG_BEHAVIOR_ADD_META="$FLAG_Y"


migrateResolveDerbyPath () {
    local key="$1"
    local value="$2"

    if [[ "${key}" == "url" && "${value}" == *"db.home"* ]]; then
        if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" ]]; then
            derbyPath="/opt/jfrog/artifactory/var/data/artifactory/derby"
            value=$(echo "${value}" | sed "s|{db.home}|$derbyPath|")
        else
            derbyPath="${NEW_DATA_DIR}/data/artifactory/derby"
            value=$(echo "${value}" | sed "s|{db.home}|$derbyPath|")
        fi
    fi
    echo "${value}"
}

migrateResolveHaDirPath () {
    local key="$1"
    local value="$2"

    if [[ "${INSTALLER}" == "${RPM_TYPE}" || "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" || "${INSTALLER}" == "${DEB_TYPE}" ]]; then
        if [[ "${key}" == "artifactory.ha.data.dir" || "${key}" == "artifactory.ha.backup.dir" ]]; then
            value=$(checkPathResolver "${value}")
        fi
    fi
    echo "${value}"
}
updatePostgresUrlString_Hook () {
    local yamlPath="$1"
    local value="$2"
    local hostIp=$(io_getPublicHostIP)
    local sourceKey="//postgresql:"
    if [[ "${yamlPath}" == "shared.database.url" ]]; then
        value=$(io_replaceString "${value}" "${sourceKey}" "//${hostIp}:" "#")
    fi
    echo "${value}"
}
# Check Artifactory product version
checkArtifactoryVersion () {
    local minProductVersion="6.0.0"
    local maxProductVersion="7.0.0"
    local propertyInDocker="ARTIFACTORY_VERSION"
    local property="artifactory.version"
    
    if [[ "${INSTALLER}" ==  "${COMPOSE_TYPE}" ]]; then
        local newfilePath="${APP_DIR}/../.env"
        local oldfilePath="${OLD_DATA_DIR}/etc/artifactory.properties"
    elif [[ "${INSTALLER}" ==  "${HELM_TYPE}" ]]; then
        local oldfilePath="${OLD_DATA_DIR}/etc/artifactory.properties"
    elif [[ "${INSTALLER}" ==  "${ZIP_TYPE}" ]]; then
        local newfilePath="${NEW_DATA_DIR}/etc/artifactory/artifactory.properties"
        local oldfilePath="${OLD_DATA_DIR}/etc/artifactory.properties"
    else
        local newfilePath="${NEW_DATA_DIR}/etc/artifactory/artifactory.properties"
        local oldfilePath="/etc/opt/jfrog/artifactory/artifactory.properties"
    fi

    getProductVersion "${minProductVersion}" "${maxProductVersion}" "${newfilePath}" "${oldfilePath}" "${propertyInDocker}" "${property}"
}

getCustomDataDir_hook () {
    retrieveYamlValue "migration.oldDataDir" "oldDataDir" "Fail"
    OLD_DATA_DIR="${YAML_VALUE}"
}

# Get protocol value of connector
getXmlConnectorProtocol () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local protocolValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@protocol' ${filePath}/${fileName} 2>/dev/null |awk -F"=" '{print $2}' | tr -d '"')
    echo -e "${protocolValue}"
}

# Get all attributes of connector
getXmlConnectorAttributes () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local connectorAttributes=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@*' ${filePath}/${fileName} 2>/dev/null)
    # strip leading and trailing spaces
    connectorAttributes=$(io_trim "${connectorAttributes}")
    echo "${connectorAttributes}"
}

# Get port value of connector
getXmlConnectorPort () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local portValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@port' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
    echo -e "${portValue}"
}

# Get maxThreads value of connector
getXmlConnectorMaxThreads () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local maxThreadValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@maxThreads' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
    echo -e "${maxThreadValue}"
}
# Get sendReasonPhrase value of connector
getXmlConnectorSendReasonPhrase () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local sendReasonPhraseValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@sendReasonPhrase' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
    echo -e "${sendReasonPhraseValue}"
}
# Get relaxedPathChars value of connector
getXmlConnectorRelaxedPathChars () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local relaxedPathCharsValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@relaxedPathChars' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
    # strip leading and trailing spaces
    relaxedPathCharsValue=$(io_trim "${relaxedPathCharsValue}")
    echo -e "${relaxedPathCharsValue}"
}
# Get relaxedQueryChars value of connector
getXmlConnectorRelaxedQueryChars () {
    local i="$1"
    local filePath="$2"
    local fileName="$3"
    local relaxedQueryCharsValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@relaxedQueryChars' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
    # strip leading and trailing spaces
    relaxedQueryCharsValue=$(io_trim "${relaxedQueryCharsValue}")
    echo -e "${relaxedQueryCharsValue}"
}

# Updating system.yaml with Connector port 
setConnectorPort () {
    local yamlPath="$1"
    local valuePort="$2"
    local portYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z "${valuePort}" ]]; then
        warn "port value is empty, could not migrate to system.yaml"
        return
    fi
    ## Getting port yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" portYamlPath "Warning"
    portYamlPath="${YAML_VALUE}"
    if [[ -z "${portYamlPath}" ]]; then
        return
    fi
    setSystemValue "${portYamlPath}" "${valuePort}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${portYamlPath}] with value [${valuePort}] in system.yaml"
}

# Updating system.yaml with Connector maxThreads
setConnectorMaxThread () {
    local yamlPath="$1"
    local threadValue="$2"
    local maxThreadYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z  "${threadValue}" ]]; then
        return
    fi
    ## Getting max Threads yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" maxThreadYamlPath "Warning"
    maxThreadYamlPath="${YAML_VALUE}"
    if [[ -z "${maxThreadYamlPath}" ]]; then
        return
    fi
    setSystemValue "${maxThreadYamlPath}" "${threadValue}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${maxThreadYamlPath}] with value [${threadValue}] in system.yaml"
}

# Updating system.yaml with Connector sendReasonPhrase
setConnectorSendReasonPhrase () {
    local yamlPath="$1"
    local sendReasonPhraseValue="$2"
    local sendReasonPhraseYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z  "${sendReasonPhraseValue}" ]]; then
        return
    fi
    ## Getting sendReasonPhrase yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" sendReasonPhraseYamlPath "Warning"
    sendReasonPhraseYamlPath="${YAML_VALUE}"
    if [[ -z "${sendReasonPhraseYamlPath}" ]]; then
        return
    fi
    setSystemValue "${sendReasonPhraseYamlPath}" "${sendReasonPhraseValue}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${sendReasonPhraseYamlPath}] with value [${sendReasonPhraseValue}] in system.yaml"
}

# Updating system.yaml with Connector relaxedPathChars
setConnectorRelaxedPathChars () {
    local yamlPath="$1"
    local relaxedPathCharsValue="$2"
    local relaxedPathCharsYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z  "${relaxedPathCharsValue}" ]]; then
        return
    fi
    ## Getting relaxedPathChars yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" relaxedPathCharsYamlPath "Warning"
    relaxedPathCharsYamlPath="${YAML_VALUE}"
    if [[ -z "${relaxedPathCharsYamlPath}" ]]; then
        return
    fi
    setSystemValue "${relaxedPathCharsYamlPath}" "${relaxedPathCharsValue}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${relaxedPathCharsYamlPath}] with value [${relaxedPathCharsValue}] in system.yaml"
}

# Updating system.yaml with Connector relaxedQueryChars
setConnectorRelaxedQueryChars () {
    local yamlPath="$1"
    local relaxedQueryCharsValue="$2"
    local relaxedQueryCharsYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z  "${relaxedQueryCharsValue}" ]]; then
        return
    fi
    ## Getting relaxedQueryChars yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" relaxedQueryCharsYamlPath "Warning"
    relaxedQueryCharsYamlPath="${YAML_VALUE}"
    if [[ -z "${relaxedQueryCharsYamlPath}" ]]; then
        return
    fi
    setSystemValue "${relaxedQueryCharsYamlPath}" "${relaxedQueryCharsValue}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${relaxedQueryCharsYamlPath}] with value [${relaxedQueryCharsValue}] in system.yaml"
}

# Updating system.yaml with Connectors configurations
setConnectorExtraConfig () {
    local yamlPath="$1"
    local connectorAttributes="$2"
    local extraConfigPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z "${connectorAttributes}" ]]; then
        return
    fi
    ## Getting extraConfig yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" extraConfig "Warning"
    extraConfigPath="${YAML_VALUE}"
    if [[ -z "${extraConfigPath}" ]]; then
        return
    fi
    # strip leading and trailing spaces
    connectorAttributes=$(io_trim "${connectorAttributes}")
    setSystemValue "${extraConfigPath}" "${connectorAttributes}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${extraConfigPath}] with connector attributes in system.yaml"
}

# Updating system.yaml with extra Connectors
setExtraConnector () {
    local yamlPath="$1"
    local extraConnector="$2"
    local extraConnectorYamlPath=
    if [[ -z "${yamlPath}" ]]; then
        return
    fi
    if [[ -z "${extraConnector}" ]]; then
        return
    fi
    ## Getting extraConnecotr yaml path from migration info yaml
    retrieveYamlValue "${yamlPath}" extraConnectorYamlPath "Warning"
    extraConnectorYamlPath="${YAML_VALUE}"
    if [[ -z "${extraConnectorYamlPath}" ]]; then
        return
    fi
    getYamlValue  "${extraConnectorYamlPath}"  "${SYSTEM_YAML_PATH}"  "false"
    local connectorExtra="${YAML_VALUE}"
    if [[ -z "${connectorExtra}" ]]; then
        setSystemValue "${extraConnectorYamlPath}" "${extraConnector}" "${SYSTEM_YAML_PATH}"
        logger "Setting [${extraConnectorYamlPath}] with extra connectors in system.yaml"
    else    
        setSystemValue "${extraConnectorYamlPath}" "\"${connectorExtra} ${extraConnector}\"" "${SYSTEM_YAML_PATH}"
        logger "Setting [${extraConnectorYamlPath}] with extra connectors in system.yaml"
    fi
}

# Migrate extra connectors to system.yaml
migrateExtraConnectors () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local excludeDefaultPort="$4"
    local i="$5"
    local extraConfig= 
    local extraConnector=
    if [[ "${excludeDefaultPort}" == "yes" ]]; then
        for ((i = 1 ; i <= "${connectorCount}" ; i++));
        do  
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            [[ "${portValue}" != "${DEFAULT_ACCESS_PORT}" && "${portValue}" != "${DEFAULT_RT_PORT}" ]] || continue
            extraConnector=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']' ${filePath}/${fileName} 2>/dev/null)
            setExtraConnector "${EXTRA_CONFIG_YAMLPATH}" "${extraConnector}" 
        done
    else
        extraConnector=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']' ${filePath}/${fileName} 2>/dev/null)
        setExtraConnector "${EXTRA_CONFIG_YAMLPATH}" "${extraConnector}"
    fi
}

# Migrate connector configurations
migrateConnectorConfig () {
    local i="$1"
    local protocolType="$2"
    local portValue="$3"
    local connectorPortYamlPath="$4"
    local connectorMaxThreadYamlPath="$5"
    local connectorAttributesYamlPath="$6"
    local filePath="$7"
    local fileName="$8"
    local connectorSendReasonPhraseYamlPath="$9"
    local connectorRelaxedPathCharsYamlPath="${10}"
    local connectorRelaxedQueryCharsYamlPath="${11}"
    
    # migrate port
    setConnectorPort "${connectorPortYamlPath}" "${portValue}"
    
    # migrate maxThreads
    local maxThreadValue=$(getXmlConnectorMaxThreads "$i" "${filePath}" "${fileName}")
    setConnectorMaxThread "${connectorMaxThreadYamlPath}" "${maxThreadValue}"

    # migrate sendReasonPhrase
    local sendReasonPhraseValue=$(getXmlConnectorSendReasonPhrase "$i" "${filePath}" "${fileName}")
    setConnectorSendReasonPhrase "${connectorSendReasonPhraseYamlPath}" "${sendReasonPhraseValue}"
    
    # migrate relaxedPathChars
    local relaxedPathCharsValue=$(getXmlConnectorRelaxedPathChars "$i" "${filePath}" "${fileName}")
    setConnectorRelaxedPathChars "${connectorRelaxedPathCharsYamlPath}" "\"${relaxedPathCharsValue}\""
    # migrate relaxedQueryChars
    local relaxedQueryCharsValue=$(getXmlConnectorRelaxedQueryChars "$i" "${filePath}" "${fileName}")
    setConnectorRelaxedQueryChars "${connectorRelaxedQueryCharsYamlPath}" "\"${relaxedQueryCharsValue}\""

    # migrate all attributes to extra config except port , maxThread , sendReasonPhrase ,relaxedPathChars and relaxedQueryChars
    local connectorAttributes=$(getXmlConnectorAttributes "$i" "${filePath}" "${fileName}")
    connectorAttributes=$(echo "${connectorAttributes}" | sed 's/port="'${portValue}'"//g' | sed 's/maxThreads="'${maxThreadValue}'"//g' | sed 's/sendReasonPhrase="'${sendReasonPhraseValue}'"//g' | sed 's/relaxedPathChars="\'${relaxedPathCharsValue}'\"//g' | sed 's/relaxedQueryChars="\'${relaxedQueryCharsValue}'\"//g')
    # strip leading and trailing spaces
    connectorAttributes=$(io_trim "${connectorAttributes}")
    setConnectorExtraConfig "${connectorAttributesYamlPath}" "${connectorAttributes}"
}

# Check for default port 8040 and 8081 in connectors and migrate
migrateConnectorPort () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local defaultPort="$4"
    local connectorPortYamlPath="$5"
    local connectorMaxThreadYamlPath="$6"
    local connectorAttributesYamlPath="$7"
    local connectorSendReasonPhraseYamlPath="$8"
    local connectorRelaxedPathCharsYamlPath="$9"
    local connectorRelaxedQueryCharsYamlPath="${10}"
    local portYamlPath=
    local maxThreadYamlPath=
    local status=
    for ((i = 1 ; i <= "${connectorCount}" ; i++));
    do  
        local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
        local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
        [[ "${protocolType}" == *AJP* ]] && continue
        [[ "${portValue}" != "${defaultPort}" ]] && continue
        if [[ "${portValue}" == "${DEFAULT_RT_PORT}" ]]; then
            RT_DEFAULTPORT_STATUS=success
        else
            AC_DEFAULTPORT_STATUS=success
        fi
        migrateConnectorConfig "${i}" "${protocolType}" "${portValue}" "${connectorPortYamlPath}" "${connectorMaxThreadYamlPath}" "${connectorAttributesYamlPath}" "${filePath}" "${fileName}" "${connectorSendReasonPhraseYamlPath}" "${connectorRelaxedPathCharsYamlPath}" "${connectorRelaxedQueryCharsYamlPath}"
    done
}

# migrate to extra, connector having default port and protocol is AJP
migrateDefaultPortIfAjp () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local defaultPort="$4"
    
    for ((i = 1 ; i <= "${connectorCount}" ; i++));
    do  
        local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
        local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
        [[ "${protocolType}" != *AJP* ]] && continue
        [[ "${portValue}" != "${defaultPort}" ]] && continue
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "no" "${i}"
    done

}

# Comparing max threads in connectors
compareMaxThreads () {
    local firstConnectorMaxThread="$1"
    local firstConnectorNode="$2"
    local secondConnectorMaxThread="$3"
    local secondConnectorNode="$4"
    local filePath="$5"
    local fileName="$6"

    # choose higher maxThreads connector as Artifactory.
    if [[ "${firstConnectorMaxThread}" -gt ${secondConnectorMaxThread} || "${firstConnectorMaxThread}" -eq ${secondConnectorMaxThread} ]]; then
        # maxThread is higher in firstConnector,
        # Taking firstConnector as Artifactory and SecondConnector as Access
        # maxThread is equal in both connector,considering firstConnector as Artifactory and SecondConnector as Access
        local rtPortValue=$(getXmlConnectorPort "${firstConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${firstConnectorNode}" "${protocolType}" "${rtPortValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
        local acPortValue=$(getXmlConnectorPort "${secondConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${secondConnectorNode}" "${protocolType}" "${acPortValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
    else
        # maxThread is higher in SecondConnector, 
        # Taking SecondConnector as Artifactory and firstConnector as Access
        local rtPortValue=$(getXmlConnectorPort "${secondConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${secondConnectorNode}" "${protocolType}" "${rtPortValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
        local acPortValue=$(getXmlConnectorPort "${firstConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${firstConnectorNode}" "${protocolType}" "${acPortValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
    fi
}

# Check max threads exist to compare
maxThreadsExistToCompare () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local firstConnectorMaxThread=
    local secondConnectorMaxThread=
    local firstConnectorNode=
    local secondConnectorNode=
    local status=success
    local firstnode=fail

    for ((i = 1 ; i <= "${connectorCount}" ; i++));
        do 
        local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
        if [[ ${protocolType} == *AJP* ]]; then
            # Migrate Connectors
            migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "no" "${i}"
            continue
        fi
        # store maxthreads value of each connector
        if [[ ${firstnode} == "fail" ]]; then
            firstConnectorMaxThread=$(getXmlConnectorMaxThreads "${i}" "${filePath}" "${fileName}")
            firstConnectorNode="${i}"
            firstnode=success
        else
            secondConnectorMaxThread=$(getXmlConnectorMaxThreads "${i}" "${filePath}" "${fileName}")
            secondConnectorNode="${i}"
        fi
    done
    [[ -z "${firstConnectorMaxThread}" ]] && status=fail
    [[ -z "${secondConnectorMaxThread}" ]] && status=fail
    # maxThreads is set, now compare MaxThreads
    if [[ "${status}" == "success" ]]; then
        compareMaxThreads "${firstConnectorMaxThread}" "${firstConnectorNode}" "${secondConnectorMaxThread}" "${secondConnectorNode}" "${filePath}" "${fileName}"
    else 
        # Assume first connector is RT, maxThreads is not set in both connectors
        local rtPortValue=$(getXmlConnectorPort "${firstConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${firstConnectorNode}" "${protocolType}" "${rtPortValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
        local acPortValue=$(getXmlConnectorPort "${secondConnectorNode}" "${filePath}" "${fileName}")
        migrateConnectorConfig "${secondConnectorNode}" "${protocolType}" "${acPortValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
    fi
}

migrateExtraBasedOnNonAjpCount () {
    local nonAjpCount="$1"
    local filePath="$2"
    local fileName="$3"
    local connectorCount="$4"
    local i="$5"

    local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
    if [[ "${protocolType}" == *AJP* ]]; then
        if [[ "${nonAjpCount}" -eq 1  ]]; then
            # migrateExtraConnectors
            migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "no" "${i}"
            continue
        else
            # migrateExtraConnectors
            migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
            continue
        fi
    fi
}

# find RT and AC Connector
findRtAndAcConnector () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local initialAjpCount=0
    local nonAjpCount=0

    # get the count of non AJP
    for ((i = 1 ; i <= "${connectorCount}" ; i++));
    do  
        local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
        local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
        [[ "${protocolType}" != *AJP* ]]  || continue
        nonAjpCount=$((initialAjpCount+1))
        initialAjpCount="${nonAjpCount}"
    done
    if [[ "${nonAjpCount}" -eq 1 ]]; then  
        # Add the connector found as access and artifactory connectors
        # Mark port as 8040 for access
        for ((i = 1 ; i <= "${connectorCount}" ; i++))
        do  
            migrateExtraBasedOnNonAjpCount "${nonAjpCount}" "${filePath}" "${fileName}" "${connectorCount}"  "$i"
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
            migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
            setConnectorPort "${AC_PORT_YAMLPATH}" "${DEFAULT_ACCESS_PORT}"
        done
    elif [[ "${nonAjpCount}" -eq 2 ]]; then
        # compare maxThreads in both connectors
        maxThreadsExistToCompare "${filePath}" "${fileName}" "${connectorCount}"
    elif [[ "${nonAjpCount}" -gt 2 ]]; then
        # migrateExtraConnectors
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
    elif [[ "${nonAjpCount}" -eq 0 ]]; then
        # setting with default port in system.yaml
        setConnectorPort "${RT_PORT_YAMLPATH}" "${DEFAULT_RT_PORT}"
        setConnectorPort "${AC_PORT_YAMLPATH}" "${DEFAULT_ACCESS_PORT}"
        # migrateExtraConnectors
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
    fi
}

# get the count of non AJP
getCountOfNonAjp () {
    local port="$1"
    local connectorCount="$2"
    local filePath=$3
    local fileName=$4
    local initialNonAjpCount=0

    for ((i = 1 ; i <= "${connectorCount}" ; i++));
    do  
        local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
        local protocolType=$(getXmlConnectorProtocol "$i" "${filePath}" "${fileName}")
        [[ "${portValue}" != "${port}" ]] || continue
        [[ "${protocolType}" != *AJP* ]]  || continue
        local nonAjpCount=$((initialNonAjpCount+1))
        initialNonAjpCount="${nonAjpCount}"
    done
    echo -e "${nonAjpCount}"
}

# Find for access connector
findAcConnector () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    
    # get the count of non AJP 
    local nonAjpCount=$(getCountOfNonAjp "${DEFAULT_RT_PORT}" "${connectorCount}" "${filePath}" "${fileName}")
    if [[ "${nonAjpCount}" -eq 1 ]]; then
        # Add the connector found as access connector and mark port as that of connector
        for ((i = 1 ; i <= "${connectorCount}" ; i++))
        do  
            migrateExtraBasedOnNonAjpCount "${nonAjpCount}" "${filePath}" "${fileName}" "${connectorCount}" "$i"
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            if [[ "${portValue}" != "${DEFAULT_RT_PORT}" ]]; then
                migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
            fi   
        done
    elif [[ "${nonAjpCount}" -gt 1 ]]; then
        # Take RT properties into access with 8040
        for ((i = 1 ; i <= "${connectorCount}" ; i++))
        do  
            migrateExtraBasedOnNonAjpCount "${nonAjpCount}" "${filePath}" "${fileName}" "${connectorCount}" "$i"
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            if [[ "${portValue}" == "${DEFAULT_RT_PORT}" ]]; then
                migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${AC_SENDREASONPHRASE_YAMLPATH}"
                setConnectorPort "${AC_PORT_YAMLPATH}" "${DEFAULT_ACCESS_PORT}"
            fi
        done
    elif [[ "${nonAjpCount}" -eq 0 ]]; then 
        # Add RT connector details as access connector and mark port as 8040  
        migrateConnectorPort "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_RT_PORT}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${AC_SENDREASONPHRASE_YAMLPATH}"
        setConnectorPort "${AC_PORT_YAMLPATH}" "${DEFAULT_ACCESS_PORT}"
        # migrateExtraConnectors
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
    fi
}

# Find for artifactory connector
findRtConnector () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    
    # get the count of non AJP 
    local nonAjpCount=$(getCountOfNonAjp "${DEFAULT_ACCESS_PORT}" "${connectorCount}" "${filePath}" "${fileName}")
    if [[ "${nonAjpCount}" -eq 1 ]]; then
        # Add the connector found as RT connector
        for ((i = 1 ; i <= "${connectorCount}" ; i++))
        do  
            migrateExtraBasedOnNonAjpCount "${nonAjpCount}" "${filePath}" "${fileName}" "${connectorCount}" "$i"
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            if [[ "${portValue}" != "${DEFAULT_ACCESS_PORT}" ]]; then
                migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
            fi
        done
    elif [[ "${nonAjpCount}" -gt 1 ]]; then
        # Take access properties into artifactory with 8081
        for ((i = 1 ; i <= "${connectorCount}" ; i++))
        do  
            migrateExtraBasedOnNonAjpCount "${nonAjpCount}" "${filePath}" "${fileName}" "${connectorCount}" "$i"
            local portValue=$(getXmlConnectorPort "$i" "${filePath}" "${fileName}")
            if [[ "${portValue}" == "${DEFAULT_ACCESS_PORT}" ]]; then
                migrateConnectorConfig "$i" "${protocolType}" "${portValue}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${filePath}" "${fileName}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
                setConnectorPort "${RT_PORT_YAMLPATH}" "${DEFAULT_RT_PORT}"
            fi
        done
    elif [[ "${nonAjpCount}" -eq 0 ]]; then   
        # Add access connector details as RT connector and mark as ${DEFAULT_RT_PORT}
        migrateConnectorPort "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_ACCESS_PORT}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
        setConnectorPort "${RT_PORT_YAMLPATH}" "${DEFAULT_RT_PORT}"
        # migrateExtraConnectors
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
    fi
}

checkForTlsConnector () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    for ((i = 1 ; i <= "${connectorCount}" ; i++))
    do
        local sslProtocolValue=$($LIBXML2_PATH --xpath '//Server/Service/Connector['$i']/@sslProtocol' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
        if [[ "${sslProtocolValue}" == "TLS" ]]; then
            bannerImportant "NOTE: Ignoring TLS connector during migration, modify the system yaml to enable TLS. Original server.xml is saved in path [${filePath}/${fileName}]"
            TLS_CONNECTOR_EXISTS=${FLAG_Y}
            continue
        fi
    done
}

# set custom tomcat server Listeners to system.yaml
setListenerConnector () {
    local filePath="$1"
    local fileName="$2"
    local listenerCount="$3"
    for ((i = 1 ; i <= "${listenerCount}" ; i++))
    do 
        local listenerConnector=$($LIBXML2_PATH --xpath '//Server/Listener['$i']' ${filePath}/${fileName} 2>/dev/null)
        local listenerClassName=$($LIBXML2_PATH --xpath '//Server/Listener['$i']/@className' ${filePath}/${fileName} 2>/dev/null | awk -F"=" '{print $2}' | tr -d '"')
        if [[ "${listenerClassName}" == *Apr* ]]; then
            setExtraConnector "${EXTRA_LISTENER_CONFIG_YAMLPATH}" "${listenerConnector}"
        fi
    done
}
# add custom tomcat server Listeners
addTomcatServerListeners () {
    local filePath="$1"
    local fileName="$2"
    local listenerCount="$3"
    if [[ "${listenerCount}" == "0" ]]; then
        logger "No listener connectors found in the [${filePath}/${fileName}],skipping migration of listener connectors"
    else
        setListenerConnector "${filePath}" "${fileName}" "${listenerCount}"
        setSystemValue "${RT_TOMCAT_HTTPSCONNECTOR_ENABLED}" "true" "${SYSTEM_YAML_PATH}"
        logger "Setting [${RT_TOMCAT_HTTPSCONNECTOR_ENABLED}] with value [true] in system.yaml"
    fi
}

# server.xml migration operations
xmlMigrateOperation () {
    local filePath="$1"
    local fileName="$2"
    local connectorCount="$3"
    local listenerCount="$4"
    RT_DEFAULTPORT_STATUS=fail
    AC_DEFAULTPORT_STATUS=fail
    TLS_CONNECTOR_EXISTS=${FLAG_N}

    # Check for connector with TLS , if found ignore migrating it
    checkForTlsConnector "${filePath}" "${fileName}" "${connectorCount}"
    if [[ "${TLS_CONNECTOR_EXISTS}" == "${FLAG_Y}" ]]; then
        return
    fi
    addTomcatServerListeners "${filePath}" "${fileName}" "${listenerCount}"
    # Migrate RT default port from connectors 
    migrateConnectorPort "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_RT_PORT}" "${RT_PORT_YAMLPATH}" "${RT_MAXTHREADS_YAMLPATH}" "${RT_EXTRACONFIG_YAMLPATH}" "${RT_SENDREASONPHRASE_YAMLPATH}" "${RT_RELAXEDPATHCHARS_YAMLPATH}" "${RT_RELAXEDQUERYCHARS_YAMLPATH}"
    # Migrate to extra if RT default ports are AJP
    migrateDefaultPortIfAjp "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_RT_PORT}"
    # Migrate AC default port from connectors
    migrateConnectorPort "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_ACCESS_PORT}" "${AC_PORT_YAMLPATH}" "${AC_MAXTHREADS_YAMLPATH}" "${AC_EXTRACONFIG_YAMLPATH}" "${AC_SENDREASONPHRASE_YAMLPATH}"
    # Migrate to extra if access default ports are AJP
    migrateDefaultPortIfAjp "${filePath}" "${fileName}" "${connectorCount}" "${DEFAULT_ACCESS_PORT}"

    if [[ "${AC_DEFAULTPORT_STATUS}" == "success" && "${RT_DEFAULTPORT_STATUS}" == "success" ]]; then
        # RT and AC default port found
        logger "Artifactory 8081 and Access 8040 default port are found"
        migrateExtraConnectors "${filePath}" "${fileName}" "${connectorCount}" "yes"
    elif [[ "${AC_DEFAULTPORT_STATUS}" == "success" && "${RT_DEFAULTPORT_STATUS}" == "fail" ]]; then
        # Only AC default port found,find RT connector
        logger "Found Access default 8040 port"
        findRtConnector "${filePath}" "${fileName}" "${connectorCount}"
    elif [[ "${AC_DEFAULTPORT_STATUS}" == "fail" && "${RT_DEFAULTPORT_STATUS}" == "success" ]]; then
        # Only RT default port found,find AC connector
        logger "Found Artifactory default 8081 port"
        findAcConnector "${filePath}" "${fileName}" "${connectorCount}"
    elif [[ "${AC_DEFAULTPORT_STATUS}" == "fail" && "${RT_DEFAULTPORT_STATUS}" == "fail" ]]; then    
        # RT and AC default port not found, find connector
        logger "Artifactory 8081 and Access 8040 default port are not found"
        findRtAndAcConnector "${filePath}" "${fileName}" "${connectorCount}"
    fi
}

# get count of connectors
getXmlConnectorCount () {
    local filePath="$1"
    local fileName="$2"
    local count=$($LIBXML2_PATH --xpath 'count(/Server/Service/Connector)' ${filePath}/${fileName})
    echo -e "${count}"
}

# get count of listener connectors
getTomcatServerListenersCount () {
    local filePath="$1"
    local fileName="$2"
    local count=$($LIBXML2_PATH --xpath 'count(/Server/Listener)' ${filePath}/${fileName})
    echo -e "${count}"
}

# Migrate server.xml configuration to system.yaml
migrateXmlFile () {
    local xmlFiles=
    local fileName=
    local filePath=
    local sourceFilePath=
    DEFAULT_ACCESS_PORT="8040"
    DEFAULT_RT_PORT="8081"
    AC_PORT_YAMLPATH="migration.xmlFiles.serverXml.access.port"
    AC_MAXTHREADS_YAMLPATH="migration.xmlFiles.serverXml.access.maxThreads"
    AC_SENDREASONPHRASE_YAMLPATH="migration.xmlFiles.serverXml.access.sendReasonPhrase"
    AC_EXTRACONFIG_YAMLPATH="migration.xmlFiles.serverXml.access.extraConfig"
    RT_PORT_YAMLPATH="migration.xmlFiles.serverXml.artifactory.port"
    RT_MAXTHREADS_YAMLPATH="migration.xmlFiles.serverXml.artifactory.maxThreads"
    RT_SENDREASONPHRASE_YAMLPATH='migration.xmlFiles.serverXml.artifactory.sendReasonPhrase'
    RT_RELAXEDPATHCHARS_YAMLPATH='migration.xmlFiles.serverXml.artifactory.relaxedPathChars'
    RT_RELAXEDQUERYCHARS_YAMLPATH='migration.xmlFiles.serverXml.artifactory.relaxedQueryChars'
    RT_EXTRACONFIG_YAMLPATH="migration.xmlFiles.serverXml.artifactory.extraConfig"
    ROUTER_PORT_YAMLPATH="migration.xmlFiles.serverXml.router.port"
    EXTRA_CONFIG_YAMLPATH="migration.xmlFiles.serverXml.extra.config"
    EXTRA_LISTENER_CONFIG_YAMLPATH="migration.xmlFiles.serverXml.extra.listener"
    RT_TOMCAT_HTTPSCONNECTOR_ENABLED="artifactory.tomcat.httpsConnector.enabled"

    retrieveYamlValue "migration.xmlFiles" "xmlFiles" "Skip"
    xmlFiles="${YAML_VALUE}"
    if [[ -z "${xmlFiles}" ]]; then
        return
    fi
    bannerSection "PROCESSING MIGRATION OF XML FILES"
    retrieveYamlValue "migration.xmlFiles.serverXml.fileName" "fileName" "Warning"
    fileName="${YAML_VALUE}"
    if [[ -z "${fileName}" ]]; then
        return
    fi
    bannerSubSection "Processing Migration of $fileName"
    retrieveYamlValue "migration.xmlFiles.serverXml.filePath" "filePath" "Warning"
    filePath="${YAML_VALUE}"
    if [[ -z "${filePath}" ]]; then
        return
    fi
    # prepend NEW_DATA_DIR only if filePath is relative path
    sourceFilePath=$(prependDir "${filePath}" "${NEW_DATA_DIR}/${filePath}")
    if [[ "$(checkFileExists "${sourceFilePath}/${fileName}")" == "true" ]]; then
        logger "File [${fileName}] is found in path [${sourceFilePath}]"
        local connectorCount=$(getXmlConnectorCount "${sourceFilePath}" "${fileName}")
        if [[ "${connectorCount}" == "0" ]]; then
            logger "No connectors found in the [${filePath}/${fileName}],skipping migration of xml configuration"
            return
        fi
        local listenerCount=$(getTomcatServerListenersCount "${sourceFilePath}" "${fileName}")
        xmlMigrateOperation "${sourceFilePath}" "${fileName}" "${connectorCount}" "${listenerCount}"
    else
        logger "File [${fileName}] is not found in path [${sourceFilePath}] to migrate"
    fi   
}

compareArtifactoryUser () {
    local property="$1"
    local oldPropertyValue="$2"
    local newPropertyValue="$3"
    local yamlPath="$4"
    local sourceFile="$5"

    if [[ "${oldPropertyValue}" != "${newPropertyValue}" ]]; then
        setSystemValue "${yamlPath}" "${oldPropertyValue}" "${SYSTEM_YAML_PATH}"
        logger "Setting [${yamlPath}] with value of the property [${property}] in system.yaml"
    else
        logger "No change in property [${property}] value in [${sourceFile}] to migrate"
    fi
}

migrateReplicator () {
    local property="$1"
    local oldPropertyValue="$2"
    local yamlPath="$3"

    setSystemValue "${yamlPath}" "${oldPropertyValue}" "${SYSTEM_YAML_PATH}"
    logger "Setting [${yamlPath}] with value of the property [${property}] in system.yaml"
}

compareJavaOptions () {
    local property="$1"
    local oldPropertyValue="$2"
    local newPropertyValue="$3"
    local yamlPath="$4"
    local sourceFile="$5"
    local oldJavaOption=
    local newJavaOption=
    local extraJavaOption=
    local check=false
    local success=true
    local status=true

    oldJavaOption=$(echo "${oldPropertyValue}" | awk 'BEGIN{FS=OFS="\""}{for(i=2;i<NF;i+=2)gsub(/ /,"@",$i)}1')
    newJavaOption=$(echo "${newPropertyValue}" | awk 'BEGIN{FS=OFS="\""}{for(i=2;i<NF;i+=2)gsub(/ /,"@",$i)}1')
    for oldJavaOption in $oldPropertyValue;
    do
        for newJavaOption in $newPropertyValue;
        do
            if [[ "${oldJavaOption}" == "${newJavaOption}" ]]; then
                check=true
                break
            else
                check=false
            fi
        done
        if [[ "${check}" == "false" ]]; then
            oldJavaOption=$(echo "${oldJavaOption}" | tr -s "@" " ")
            getYamlValue "${yamlPath}" "${SYSTEM_YAML_PATH}" "false"
            extraJavaOption="${YAML_VALUE}"
            success=false
            if [[ -z "${extraJavaOption}" ]]; then
                setSystemValue "${yamlPath}" "\"${oldJavaOption}\"" "${SYSTEM_YAML_PATH}" && status=false
            else
                [[ "${extraJavaOption}" != *"${oldJavaOption}"* ]] && setSystemValue "${yamlPath}" "\"${extraJavaOption} ${oldJavaOption}\"" "${SYSTEM_YAML_PATH}" || status=false
            fi
        fi
    done
    if [[ "${status}" == "false" ]]; then
        getYamlValue "${yamlPath}" "${SYSTEM_YAML_PATH}" "false"
        local extraOpts="${YAML_VALUE}"
        logger "Setting [${yamlPath}] with value of the property [${property}] in system.yaml"
    fi
    [[ "${success}" == "true" && "${check}" == "true" ]] && logger "No change in property [JAVA_OPTIONS] value in [${sourceFile}] to migrate"
}

defaultPropertyMigrate () {
    local entry="$1"
    local sourceFile="$2"
    local targetFile="$3"
    local yamlPath=
    local property=
    local oldPropertyValue=
    local newPropertyValue=
    local check=false
    
    local targetDataDir=

    local yamlPath=$(getFirstEntry "${entry}")
    local property=$(getSecondEntry "${entry}")
    if [[ -z "${property}" ]]; then
        warn "Property is empty in map [${entry}] in the file [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    if [[ -z "${yamlPath}" ]]; then
        warn "yamlPath is empty for [${property}] in [${MIGRATION_SYSTEM_YAML_INFO}]"
        return
    fi
    unset ${property}
    source ${sourceFile}
    oldPropertyValue=$(evalVariable "oldPropertyValue" "${property}")

    unset ${property}
    source ${targetFile}
    if [[ "${property}" == "JAVA_OPTIONS" ]]; then
        property="DEFAULT_JAVA_OPTIONS"
    fi
    newPropertyValue="$(evalVariable "newPropertyValue" "${property}")"

    [[ -z "${oldPropertyValue}" ]] && logger "Property [${property}] not found in [${sourceFile}] to migrate" || check=true
    if [[ "${check}" == "true" ]]; then
        # migrate ARTIFACTORY_USER
        [[ "${property}" == "ARTIFACTORY_USER" ]] && compareArtifactoryUser "${property}" "${oldPropertyValue}" "${newPropertyValue}" "${yamlPath}" "${sourceFile}"
        # migrate JAVA_OPTIONS
        [[ "${property}" == *"JAVA_OPTIONS"* ]] && compareJavaOptions "${property}" "${oldPropertyValue}" "${newPropertyValue}" "${yamlPath}" "${sourceFile}"
        # migrate START_LOCAL_REPLICATOR
        [[ "${property}" == "START_LOCAL_REPLICATOR" ]] && migrateReplicator "${property}" "${oldPropertyValue}" "${yamlPath}"
    fi
}

migrateDefaultFile () {
    local oldDefaultFilePath=
    local newDefaultFilePath=
    local oldfileName=
    local newFileName=
    local map=
    local defaultFile=
    local sourceFilePath=
    local targetFilePath=
    local sourceFile=
    local targetFile=
    
    retrieveYamlValue "migration.defaultFile" "defaultFile" "Skip"
    defaultFile="${YAML_VALUE}"
    if [[ -z "${defaultFile}" ]]; then
        return
    fi
    bannerSection "PROCESSING MIGRATION OF DEFAULTFILE"
    retrieveYamlValue "migration.defaultFile.oldFile.defaultFilePath" "oldDefaultFilePath" "Warning"
    oldDefaultFilePath="${YAML_VALUE}"
    retrieveYamlValue "migration.defaultFile.oldFile.fileName" "oldFileName" "Warning"
    oldFileName="${YAML_VALUE}"
    if [[ "$(warnIfEmpty "${oldDefaultFilePath}" "migration.defaultFile.oldFile.defaultFilePath")" != "true" ]]; then
        return
    fi
    if [[ "$(warnIfEmpty "${oldFileName}" "migration.defaultFile.oldFile.fileName")" != "true" ]]; then
        return
    fi
    retrieveYamlValue "migration.defaultFile.newFile.defaultFilePath" "newDefaultFilePath" "Warning"
    newDefaultFilePath="${YAML_VALUE}"
    retrieveYamlValue "migration.defaultFile.newFile.fileName" "newfileName" "Warning"
    newFileName="${YAML_VALUE}"
    if [[ "$(warnIfEmpty "${newDefaultFilePath}" "migration.defaultFile.newFile.defaultFilePath")" != "true" ]]; then
        return
    fi
    if [[ "$(warnIfEmpty "${newFileName}" "migration.defaultFile.newFile.fileName")" != "true" ]]; then
        return
    fi
    # prepend NEW_DATA_DIR only if oldDefaultFilePath is relative path
    sourceFilePath=$(prependDir "${oldDefaultFilePath}" ${NEW_DATA_DIR}/${oldDefaultFilePath})
    sourceFile="${sourceFilePath}/${oldFileName}"
    if [[ "$(checkFileExists "${sourceFile}")" != "true" ]]; then
        logger "OldDefaultFile [${oldFileName}] not found in the path [${sourceFilePath}]"
        return
    fi
    # path newDefaultFilePath will change based installer
    if [[ "${INSTALLER}" == "${ZIP_TYPE}" ]]; then
        targetFilePath="${APP_DIR}/../${newDefaultFilePath}"
    else
        targetDataDir="`cd "${NEW_DATA_DIR}"/../;pwd`"
        targetFilePath="${targetDataDir}/${newDefaultFilePath}"
    fi
    targetFile="${targetFilePath}/${newFileName}"
    if [[ "$(checkFileExists "${targetFile}")" != "true" ]]; then
        logger "NewDefaultFile [${newFileName}] not found in the path [${sourceFilePath}]"
        return
    fi
    logger "OldDefaultFile [${oldFileName}] found in the path [${sourceFilePath}]"
    logger "NewDefaultFile [${newFileName}] found in the path [${targetFilePath}]"
    retrieveYamlValue "migration.defaultFile.map" "map" "Warning"
    map="${YAML_VALUE}"
    [[ -z "${map}" ]] && continue
    for entry in $map;
    do
        if [[ "$(checkMapEntry "${entry}")" == "true" ]]; then
            defaultPropertyMigrate "${entry}" "${sourceFile}" "${targetFile}"
        else
            warn "map entry [${entry}] in [${MIGRATION_SYSTEM_YAML_INFO}] is not in correct format, correct format i.e yamlPath=property"
        fi
    done
}

# comment node.id in system.yaml
# Add a commented Line above the node.id in system.yaml
commentNodeId () {
    local filePath=
    local fileName=
    local idKey=

    retrieveYamlValue "migration.propertyFiles.haNodeProperty.filePath" "filePath" "Skip"
    filePath="${YAML_VALUE}"
    if [[ -z "${filePath}" ]]; then
        return
    fi
    retrieveYamlValue "migration.propertyFiles.haNodeProperty.fileName" "fileName" "Skip"
    fileName="${YAML_VALUE}"
    if [[ -z "${fileName}" ]]; then
        return
    fi
    if [[ "$(checkFileExists "${NEW_DATA_DIR}/${filePath}/${fileName}")" == "true" ]]; then
        getYamlValue "shared.node" "${SYSTEM_YAML_PATH}" "false"
        idKey=$(echo "${YAML_VALUE}" | grep "^id:")
        local regexString="${idKey}"
        local replaceText="#&"
        replaceText_migration_hook "${regexString}" "${replaceText}" "${SYSTEM_YAML_PATH}"
        local text="# NOTE: node.id can be automatically determined based on the current hostname or be set using the SHARED_NODE_ID environment variable. There is no need to explicitly specify it here."
        prependText "${regexString}" "${text}" "${SYSTEM_YAML_PATH}"
    fi
}

artifactoryInfoMessage () {

    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        addText "# yamlFile was generated from db.properties,replicator.yaml and ha-node.properties config files." "${SYSTEM_YAML_PATH}"
    else
        addText "# yamlFile was generated from default file,replicator.yaml,db.properties and ha-node.properties config files." "${SYSTEM_YAML_PATH}"
    fi

}

replicatorProfiling () {

    if [[ "${key}" == "profilingDisabled" ]]; then
        if [[ ! -z "${value}" ]]; then
            if [[ "${value}" == "false" ]]; then
                value="true"
            else
                value="false"
            fi
        fi
    fi
}

setHaEnabled_hook () {
    local filePath="$1"
    if [[ "$(checkFileExists "${NEW_DATA_DIR}/${filePath}/ha-node.properties")" == "true" ]]; then
        setSystemValue "shared.node.haEnabled" "true" "${SYSTEM_YAML_PATH}"
        logger "Setting [shared.node.haEnabled] with [true] in system.yaml"
    fi
}

removeFileOperation () {
    local backupDir="$1"
    local file="$2"
    if [[ "$(checkFileExists "${file}")" == "true" ]]; then
        cp -pf "${file}" "${backupDir}" || warn "Failed to copy file [${file}] to ${backupDir}"
        rm -f "${file}" || warn "Failed to remove file [${file}]"
    else
        logger "Source file [${file}] does not exist in path to backup and remove"
    fi
}

_createBackupOfLogBackDir () {
    local backupDir="$1"
    local accessLogbackFile="${NEW_DATA_DIR}/etc/access/logback.xml"
    local artiLogbackFile="${NEW_DATA_DIR}/etc/artifactory/logback.xml"
    local effectiveUser=
    local effectiveGroup=
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        effectiveUser="${JF_USER}"
        effectiveGroup="${JF_USER}"
    elif [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        effectiveUser="${USER_TO_CHECK}" 
        effectiveGroup="${GROUP_TO_CHECK}"
    fi
    removeSoftLinkAndCreateDir "${backupDir}/logbackXmlFiles" "${effectiveUser}" "${effectiveGroup}" "yes"
    removeSoftLinkAndCreateDir "${backupDir}/logbackXmlFiles/access" "${effectiveUser}" "${effectiveGroup}" "yes" 
    removeSoftLinkAndCreateDir "${backupDir}/logbackXmlFiles/artifactory" "${effectiveUser}" "${effectiveGroup}" "yes"
    removeFileOperation "${backupDir}/logbackXmlFiles/access" "${accessLogbackFile}"
    removeFileOperation "${backupDir}/logbackXmlFiles/artifactory" "${artiLogbackFile}"
}


_createBackupOfReplicatorRtYaml () {
    local backupDir="$1"
    local replicatorRtYamlFile="${NEW_DATA_DIR}/etc/replicator/replicator.artifactory.yaml"
    local effectiveUser=
    local effectiveGroup=
    if [[ "${INSTALLER}" == "${COMPOSE_TYPE}" || "${INSTALLER}" == "${HELM_TYPE}" ]]; then
        effectiveUser="${JF_USER}"
        effectiveGroup="${JF_USER}"
    elif [[ "${INSTALLER}" == "${DEB_TYPE}" || "${INSTALLER}" == "${RPM_TYPE}" ]]; then
        effectiveUser="${USER_TO_CHECK}" 
        effectiveGroup="${GROUP_TO_CHECK}"
    fi
    removeSoftLinkAndCreateDir "${backupDir}/replicatorYamlFile" "${effectiveUser}" "${effectiveGroup}" "yes"
    removeFileOperation "${backupDir}/replicatorYamlFile" "${replicatorRtYamlFile}"
}

backupFiles_hook () {
    local backupDirectory="$1" 
    _createBackupOfLogBackDir "${backupDirectory}"
    _createBackupOfReplicatorRtYaml "${backupDirectory}"
}

migrateArtifactory () {
    creationMigrateLog
    _pauseExecution "creationMigrateLog"
    checkArtifactoryVersion
    _pauseExecution "checkArtifactoryVersion"
    startMigration
    _pauseExecution "startMigration"
    setSystemYamlPath
    _pauseExecution "setSystemYamlPath"
    createRequiredDirs
    _pauseExecution "createRequiredDirs"
    symlinkDirectories
    _pauseExecution "symlinkDirectories"
    copyDirectories
    _pauseExecution "copyDirectories"
    moveDirectories
    _pauseExecution "moveDirectories"
    trimMasterKey
    _pauseExecution "trimMasterKey"
    migratePropertiesFiles
    _pauseExecution "migratePropertiesFiles"
    migrateXmlFile
    _pauseExecution "migrateXmlFile"
    migrateDefaultFile
    _pauseExecution "migrateDefaultFile"
    migrateYamlFile
    _pauseExecution "migrateYamlFile"
    updateSystemYamlFile
    _pauseExecution "updateSystemYamlFile"
    cleanUpOldDataDirectories
    _pauseExecution "cleanUpOldDataDirectories"
    cleanUpOldFiles
    _pauseExecution "cleanUpOldFiles"
    commentNodeId
    _pauseExecution "commentNodeId"
    artifactoryInfoMessage
    _pauseExecution "artifactoryInfoMessage"
    endMigration
    _pauseExecution "endMigration"
}

initialize
main