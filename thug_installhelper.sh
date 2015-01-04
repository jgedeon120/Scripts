#!/bin/bash

set -e

. /etc/lsb-release

VER=$DISTRIB_RELEASE

if [ `whoami` != 'root' ]; then
	echo 'This script must be run as root'
	exit 0
fi

if [ $VER != "14.04" ]; then
	echo 'This script is meant for Ubuntu 14.04'
	exit 0
fi

# Update the system.
echo 'Checking for system updates and applying them if there are any'
apt-get update && apt-get -y dist-upgrade

# Install base packages
echo 'Installing the base packages that are needed'
apt-get -y install --no-install-recommends python-lxml python-chardet python-httplib2 python-requests libboost-python-dev libboost-system-dev libboost-thread-dev python-cssutils python-zope.interface graphviz python-pyparsing python-pydot python-magic yara python-yara python-html5lib subversion git build-essential gyp python-dev python-pip yara python-yara libemu-dev libemu2 ssdeep mongodb python-pymongo 

pip install jsbeautifier rarfile beautifulsoup4 pefile

# Install Google v8.
svn checkout http://pyv8.googlecode.com/svn/trunk/ /usr/local/src/pyv8
curl -s https://raw.githubusercontent.com/buffer/thug/master/patches/PyV8-patch1.diff -o /usr/local/src/PyV8-patch1.diff
patch -d /usr/local/src/ -p0 < /usr/local/src/PyV8-patch1.diff
svn checkout http://v8.googlecode.com/svn/trunk/ /usr/local/src/v8
export V8_HOME=/usr/local/src/v8
echo 'Building and installing Google v8'
echo 'This is expected to take a while and increase system load'
cd /usr/local/src/pyv8/ && python setup.py build && python setup.py install

# Install pylibemu
git clone https://github.com/buffer/pylibemu.git /usr/local/src/pylibemu
cd /usr/local/src/pylibemu/ && python setup.py build && python setup.py install

# Install thug
git clone https://github.com/buffer/thug.git /opt/thug
sed -i '1,/True/s/True/False/' /opt/thug/src/Logging/logging.conf
python /opt/thug/src/thug.py -h

echo 'Thug has been set up'

exit 0