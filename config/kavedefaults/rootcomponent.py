#!/usr/bin/env python
##############################################################################
#
# Copyright 2016 KPMG Advisory N.V. (unless otherwise stated)
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
"""
root.py module: installs root on top of anaconda :)
"""
import os
import sys
import kaveinstall as li
from kaveinstall import Component, linuxVersion, mycmd
from condacomponent import conda

# Ubuntu14 fix libpng
libpng = Component("libpng")
libpng.version = "1.5.22"
libpng.doInstall = True
libpng.src_from = {"suffix": ".tar.gz"}
libpng.post = {"Ubuntu14": ["bash -c 'if [ ! -e /usr/local/libpng ]; then cd libpng-1.5.22; "
                            + "./configure --prefix=/usr/local/libpng; make; make install;"
                            + " ln -s /usr/local/libpng/lib/libpng15.so.15 /usr/lib/libpng15.so.15; fi;'"]}
libpng.post["Ubuntu16"] = libpng.post["Ubuntu14"]

# Centos6 Glew Fix
glew = Component("glew")
glew.doInstall = True
glew.version = "1.5.5-1"
glew.src_from = {"suffix": ".el6.x86_64.rpm"}

# Centos6 GlewDev Fix
glewdev = Component("glew-devel")
glewdev.doInstall = True
glewdev.version = "1.5.5-1"
glewdev.pre = {"Centos6": ["yum -y install mesa-libGLU-devel"]}
glewdev.src_from = {"suffix": ".el6.x86_64.rpm"}

class RootComponent(Component):
    def script(self):
        self.run("bash -c 'source " + self.toolbox.envscript() + " > /dev/null ; conda config --add channels NLESC;'")
        self.run("bash -c 'source " + self.toolbox.envscript()
                 + " > /dev/null ; conda config --add channels https://conda.anaconda.org/nlesc/label/dev;'")
        self.run("bash -c 'source " + self.toolbox.envscript()
                 + " > /dev/null ; conda install root=" + self.version + " --yes;'")
        self.run("bash -c 'source " + self.toolbox.envscript()
                 + " > /dev/null ; conda install rootpy root-numpy root_pandas  --yes;'")

    def skipif(self):
        return (conda.installDirVersion in
                mycmd("bash -c 'source " + self.toolbox.envscript()
                      +  " > /dev/null ; which root ;'")[1]
                )

root = RootComponent("ROOT")
root.doInstall = True
root.version = "6.04"
root.pre = {"Centos7": ['yum -y groupinstall "Development Tools" "Development Libraries" "Additional Development"',
                        "wget http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6",
                        "rpm --import RPM-GPG-KEY-oracle-ol6",
                        "yum -y install libX11-devel libXpm-devel libXft-devel libXext-devel fftw-devel mysql-devel "
                        "libxml2-devel ftgl-devel glew glew-devel qt qt-devel gsl gsl-devel"
                        ],
            "Centos6": ['yum -y groupinstall "Development Tools" "Development Libraries" "Additional Development"',
                        "wget http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6",
                        "rpm --import RPM-GPG-KEY-oracle-ol6",
                        "yum -y install libX11-devel libXpm-devel libXft-devel libXext-devel fftw-devel mysql-devel "
                        "libxml2-devel ftgl-devel libglew glew glew-devel qt qt-devel gsl gsl-devel"
                        ],
            "Ubuntu14": ["apt-get -y install x11-common libx11-6 x11-utils libX11-dev libgsl0-dev gsl-bin libxpm-dev "
                         "libxft-dev g++ gfortran build-essential g++ libjpeg-turbo8-dev libjpeg8-dev libjpeg8-dev"
                         " libjpeg-dev libtiff5-dev libxml2-dev libssl-dev libgnutls-dev libgmp3-dev libpng12-dev "
                         "libldap2-dev libkrb5-dev freeglut3-dev libfftw3-dev python-dev libmysqlclient-dev libgif-dev "
                         "libiodbc2 libiodbc2-dev libxext-dev libxmu-dev libimlib2 gccxml libxml2 libglew-dev"
                         " glew-utils libc6-dev-i386"
                         ],
            "Ubuntu16": ["apt-get -y install x11-common libx11-6 x11-utils libx11-dev libgsl-dev gsl-bin libxpm-dev "
                         "libxft-dev g++ gfortran build-essential g++ libjpeg-turbo8-dev libjpeg8-dev libjpeg8-dev"
                         " libjpeg-dev libtiff5-dev libxml2-dev libssl-dev libgnutls-dev libgmp3-dev libpng12-dev "
                         "libldap2-dev libkrb5-dev freeglut3-dev libfftw3-dev python-dev libmysqlclient-dev libgif-dev "
                         "libiodbc2 libiodbc2-dev libxext-dev libxmu-dev libimlib2 gccxml libxml2 libglew-dev"
                         " glew-utils libc6-dev-i386"
                         ]
            }
root.children = {"Centos6": [glew, glewdev, conda],
                 "Centos7": [conda],
                 "Ubuntu14": [libpng, conda],
                 "Ubuntu16": [libpng, conda]
                 }
root.freespace = 2048
root.usrspace = 300
root.tempspace = 10
root.env = """
if [ -e "$ana"/bin/thisroot.sh ]; then
    source "$ana"/bin/thisroot.sh
fi
"""
root.tests = [("python -c \"import ROOT; import root_numpy; ROOT.TBrowser();\"", 0, '', '')]

__all__ = ["root"]
