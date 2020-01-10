# Python 3.7.x installer script for ubuntu 16.04
# Install requirements
sudo apt-get install build-essential
sudo apt-get install checkinstall
sudo apt-get install libreadline-gplv2-dev
sudo apt-get install libncursesw5-dev
sudo apt-get install libssl-dev
sudo apt-get install libsqlite3-dev
sudo apt-get install tk-dev
sudo apt-get install libgdbm-dev
sudo apt-get install libc6-dev
sudo apt-get install libbz2-dev
sudo apt-get install zlib1g-dev
sudo apt-get install openssl
sudo apt-get install libffi-dev
sudo apt-get install python3-dev
sudo apt-get install python3-setuptools
sudo apt-get install wget

# Prepare to build
mkdir /tmp/Python37
pushd /tmp/Python37

# Pull down Python 3.7, build, and install
PYVER=3.7.6
wget https://www.python.org/ftp/python/${PYVER}/Python-${PYVER}.tar.xz
tar xvf Python-${PYVER}.tar.xz
cd /tmp/Python37/Python-${PYVER}
./configure
sudo make altinstall

popd