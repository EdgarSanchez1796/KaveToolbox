#!/bin/bash
#CentOS7 ROOT build thsi needs to be adjusted to work on Ubuntu  as well:
set -e

TMPDIR="/tmp/rootTry"
LOGDIR="/var/log/RootInstall"
KTBRELEASE="3.2-Beta"
KTBDIR="/opt/KaveToolbox"
ANADIR="/opt/anaconda"
PYTHONVERSION="2.7"
SPARKRELEASE="2.1.0"
SPARKDIR="/opt/spark"
ROOTRELEASE="6.08.06"
ROOTDIR="/opt/root"
PYCHARMRELEASE="2016.3.3"
PYCHARMDIR="/opt/pycharm"

ln -sf /bin/bash /bin/sh

# create directories for software installation
mkdir -p "${TMPDIR}"
mkdir -p "${LOGDIR}"
cd "${TMPDIR}"

#install prereq packages
yum -y install cmake3 gcc-c++ gcc binutils clang\
libX11-devel libXpm-devel libXft-devel libXext-devel \
gcc-gfortran openssl-devel pcre-devel \
mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
fftw-devel cfitsio-devel graphviz-devel \
avahi-compat-libdns_sd-devel libldap-dev python-devel \
libxml2-devel gsl-static

## Root env. to be included in KaveEnv.sh
printf '#Begin ROOT\n\nexport ROOTSYS="/opt/root/pro"
source "${ROOTSYS}/bin/thisroot.sh"\n\n#End ROOT\n' >> "${KTBDIR}/pro/scripts/KaveEnv.sh"

mkdir -p "${ROOTDIR}"
ln -sfT "root-${ROOTRELEASE}" "${ROOTDIR}/pro"

cd "${TMPDIR}"
wget "https://root.cern.ch/download/root_v${ROOTRELEASE}.source.tar.gz"
tar -xzf "root_v${ROOTRELEASE}.source.tar.gz" --no-same-owner

# apply ROOT patches
cd "root-${ROOTRELEASE}"

for patchfile in $(ls /home/kalin/ROOT_temp/*.patch); do
  patch -p1 -i "${patchfile}"
done

# Install ROOT

cd "${TMPDIR}"
mkdir -p root_build
cd root_build

cmake3 -DCMAKE_INSTALL_PREFIX="${ROOTDIR}/root-${ROOTRELEASE}" \
  -Dfail-on-missing=ON -Dcxx11=ON\
  -Dcxx14=OFF -Droot7=ON -Dshared=ON -Dsoversion=ON -Dthread=ON -Dfortran=ON -Dpython=ON -Dcling=ON -Dx11=ON -Dssl=ON \
  -Dxml=ON -Dfftw3=ON -Dbuiltin_fftw3=OFF -Dmathmore=ON -Dminuit2=ON -Droofit=ON -Dtmva=ON -Dopengl=ON -Dgviz=ON \
  -Dalien=OFF -Dbonjour=OFF -Dcastor=OFF -Dchirp=OFF -Ddavix=OFF -Ddcache=OFF -Dfitsio=OFF -Dgfal=OFF -Dhdfs=OFF \
  -Dkrb5=OFF -Dldap=OFF -Dmonalisa=OFF -Dmysql=OFF -Dodbc=OFF -Doracle=OFF -Dpgsql=OFF -Dpythia6=OFF -Dpythia8=OFF \
  -Dsqlite=OFF -Drfio=OFF -Dxrootd=OFF \
  -DPYTHON_EXECUTABLE="${ANADIR}/pro/bin/python" \
  -DNUMPY_INCLUDE_DIR="${ANADIR}/pro/lib/python${PYTHONVERSION}/site-packages/numpy/core/include" \
  "../root-${ROOTRELEASE}"

CORESCOUNT=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
cmake3 --build . --target install -- -j${CORESCOUNT}

# install Python packages for ROOT

cd "${TMPDIR}"
git clone git://github.com/rootpy/root_numpy.git
bash -c "source ${KTBDIR}/pro/scripts/KaveEnv.sh && python ${TMPDIR}/root_numpy/setup.py install"

# For now just commenting out PyCharm code.   

## PyCharm env:
#
#printf '#Begin PyCharm\n\nexport export PYCHARM_HOME="${PYCHARMDIR}/pro"
#export PATH="${PYCHARM_HOME}/bin:${PATH}\n\n#End PyCharm\n' >> "${KTBDIR}/pro/scripts/KaveEnv.sh"
#
## Install PyCharm
#mkdir -p "${PYCHARMDIR}"
#ln -sfT "pycharm-community-${PYCHARMRELEASE}" "${PYCHARMDIR}/pro"
#cd "${TMPDIR}"
#wget -q "https://download.jetbrains.com/python/pycharm-community-${PYCHARMRELEASE}.tar.gz"
#tar -xzf "pycharm-community-${PYCHARMRELEASE}.tar.gz" --no-same-owner -C "${PYCHARMDIR}"

# Install ROOT Pandas
cd "${TMPDIR}"
git clone https://github.com/ibab/root_pandas.git
bash -c "source ${KTBDIR}/pro/scripts/KaveEnv.sh && python ${TMPDIR}/root_pandas/setup.py install"

