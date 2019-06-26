#!/bin/bash

set -e
set -u
set -o pipefail

source ${SCRIPTS_LIB_DIR}/utils.sh

BASEDIR=$1
MX=$2
GRAALVM_SUITE_RUNTIMES=$3

echo ">>> Building GraalVM Suite"
echo "JAVA_OPTS=${JAVA_OPTS}"

echo ">>>> Currently JAVA_HOME=${JAVA_HOME}"
JDK8_JVMCI_HOME="$(cd ${BASEDIR}/graal-jvmci-8/ && ${MX} --java-home ${JAVA_HOME} jdkhome)"
export JVMCI_VERSION_CHECK='ignore'
export JAVA_HOME=${JDK8_JVMCI_HOME}
echo ">>>> Newly set JAVA_HOME=${JAVA_HOME}"

${SCRIPTS_LIB_DIR}/applyPatches.sh ${BASEDIR}

cd ${BASEDIR}/graal/vm

#echo "Applying and checking patch to mx/mx_vm.py..."
#git apply ${SCRIPTS_LIB_DIR}/patch/mx_vm.py-VM-version-string-fix.patch || true
#grep "pattern \= re.compile" -B 2 mx.vm/mx_vm.py                        || true

set -x
${MX} --dy ${GRAALVM_SUITE_RUNTIMES} \
      --J @"${JAVA_OPTS}" --java-home=${JDK8_JVMCI_HOME} build
set +x
