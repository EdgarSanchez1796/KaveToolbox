#!/bin/bash
##############################################################################
#
# Copyright 2017 KPMG Advisory N.V. (unless otherwise stated)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
##############################################################################


#   This script can be used to locally build and install root if needed.

set -e

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMPDIR="/tmp/rootTmp-`date +"%d-%m-%y"`-$RANDOM"
KTBRELEASE="3.7-Beta"
KTBDIR="/opt/KaveToolbox"
ANADIR="/opt/anaconda"
ANAPYTHONVERSION=`$ANADIR/pro/bin/python -c 'import sys; version=sys.version_info[:3]; print("{0}.{1}".format(*version))'`
ROOTRELEASE="6.10.04"
ROOTDIR="/opt/root"

if [[ $PATH == ?(*:)$ANADIR/*/bin?(:*) ]] 
	then
		echo "ERROR: Anaconda found in user's PATH. Please remove it and retry";
		exit 1;
fi

CORESCOUNT=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
ln -sf /bin/bash /bin/sh

# create directories for software installation
mkdir -p "${TMPDIR}"
mkdir -p "${ROOTDIR}"
ln -sfT "root-${ROOTRELEASE}" "${ROOTDIR}/pro"

# Get ROOT sources
cd "${TMPDIR}"
wget "https://root.cern.ch/download/root_v${ROOTRELEASE}.source.tar.gz"
tar -xzf "root_v${ROOTRELEASE}.source.tar.gz" --no-same-owner

# Install ROOT
cd "${TMPDIR}"
mkdir -p root_build
cd root_build


if [ `${SCRIPTDIR}/DetectOSVersion` == "Centos7" ]; then
	CMAKECMD="cmake3"
else
	CMAKECMD="cmake"
fi

${CMAKECMD} -DCMAKE_INSTALL_PREFIX="${ROOTDIR}/root-${ROOTRELEASE}" \
	-Dfail-on-missing=ON -Dcxx11=ON\
	-Dshared=ON -Dsoversion=ON -Dthread=ON -Dfortran=ON -Dpython3=ON -Dcling=ON -Dx11=ON -Dssl=ON \
	-Dxml=ON -Dfftw3=ON -Dbuiltin_fftw3=OFF -Dmathmore=ON -Dminuit2=ON -Droofit=ON -Dtmva=ON -Dopengl=ON -Dgviz=ON \
	-Dalien=OFF -Dbonjour=OFF -Dcastor=OFF -Dchirp=OFF -Ddavix=OFF -Ddcache=OFF -Dfitsio=OFF -Dgfal=OFF -Dhdfs=OFF \
	-Dkrb5=OFF -Dldap=OFF -Dmonalisa=OFF -Dmysql=OFF -Dodbc=OFF -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF -Dpythia8=OFF \
	-Dsqlite=OFF -Drfio=OFF -Dxrootd=OFF \
	-DPYTHON_EXECUTABLE="${ANADIR}/pro/bin/python${ANAPYTHONVERSION}" \
	-DPYTHON_INCLUDE_DIRS= "${ANADIR}/pro/include/python${ANAPYTHONVERSION}m" \
	-DPYTHON_LIBRARY="${ANADIR}/pro/lib/libpython${ANAPYTHONVERSION}m.so" \
	-DNUMPY_INCLUDE_DIR="${ANADIR}/pro/lib/python${ANAPYTHONVERSION}/site-packages/numpy/core/include" \
	"../root-${ROOTRELEASE}"
	
${CMAKECMD} --build . --target install -- -j${CORESCOUNT}

# Temporary set root env.
export ROOTSYS="${ROOTDIR}/pro"
source "${ROOTSYS}/bin/thisroot.sh"

# install Python packages for ROOT
cd "${TMPDIR}"
git clone git://github.com/rootpy/root_numpy.git
bash -c "source ${KTBDIR}/pro/scripts/KaveEnv.sh > /dev/null && python ${TMPDIR}/root_numpy/setup.py install"
   
# Install ROOT Pandas
cd "${TMPDIR}"
git clone https://github.com/ibab/root_pandas.git
bash -c "source ${KTBDIR}/pro/scripts/KaveEnv.sh > /dev/null && python ${TMPDIR}/root_pandas/setup.py install"

#Cleanup Temp Dir:
rm -rf ${TMPDIR}
