#!/bin/bash

#
# Extended off the original script (see https://github.com/jponge/build-graal-jvm/blob/master/build.sh) from @jponge
#

#
# Copyright 2019 Mani Sarkar
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e
set -u
set -o pipefail

IFS=$'\n\t'

BASEDIR=$(pwd)
export RUN_TESTS=${RUN_TESTS:-"true"}
JDK_GRAAL_FOLDER_NAME=jdk8-with-graal
export GRAAL_JVMCI_8_TAG=${GRAAL_JVMCI_8_TAG:-master}
BUILD_ARTIFACTS_DIR=${BASEDIR}/${JDK_GRAAL_FOLDER_NAME}
export JAVA_OPTS="$(echo ${DOCKER_JAVA_OPTS:-""} ${JAVA_OPTS:-})"

echo ">>> Working in ${BASEDIR}"

export MX_HOME=${BASEDIR}/mx
export MX=${MX_HOME}/mx
export PATH=${MX_HOME}:$PATH

export SCRIPTS_LIB_DIR=${SCRIPTS_LIB_DIR:-$(pwd)/lib}

printParameters() {
    echo "******************* Parameters ******************"
    echo "BASEDIR=${BASEDIR}"
    echo ""
    echo "JDK_GRAAL_FOLDER_NAME=${JDK_GRAAL_FOLDER_NAME}"
    echo "GRAAL_JVMCI_8_TAG=${GRAAL_JVMCI_8_TAG}"
    echo "BUILD_ARTIFACTS_DIR=${BUILD_ARTIFACTS_DIR}"
    echo ""
    echo "RUN_TESTS=${RUN_TESTS}"
    echo "JAVA_HOME=${JAVA_HOME}"
    echo "JAVA_OPTS=${JAVA_OPTS}"
    echo ""
    echo "MX_HOME=${MX_HOME}"
    echo "MX=${MX}"
    echo "PATH=${PATH}"
    echo "*************************************************"
}

run() {
    printParameters
    ${SCRIPTS_LIB_DIR}/displayDependencyVersion.sh
    time ${SCRIPTS_LIB_DIR}/setupMX.sh ${BASEDIR}
    time ${SCRIPTS_LIB_DIR}/build_JDK_JVMCI.sh ${BASEDIR} ${MX}
    time ${SCRIPTS_LIB_DIR}/run_JDK_JVMCI_Tests.sh ${BASEDIR} ${MX}
    source ${SCRIPTS_LIB_DIR}/setEnvVariables.sh ${BASEDIR} ${MX}
    time ${SCRIPTS_LIB_DIR}/buildGraalCompiler.sh ${BASEDIR} ${MX} ${BUILD_ARTIFACTS_DIR}
    ${SCRIPTS_LIB_DIR}/sanityCheckArtifacts.sh ${BASEDIR} ${JDK_GRAAL_FOLDER_NAME}
    time ${SCRIPTS_LIB_DIR}/archivingArtifacts.sh ${BASEDIR} ${MX} ${JDK_GRAAL_FOLDER_NAME} ${BUILD_ARTIFACTS_DIR}
    time ${SCRIPTS_LIB_DIR}/archivingLogs.sh ${BASEDIR}
}

time run
