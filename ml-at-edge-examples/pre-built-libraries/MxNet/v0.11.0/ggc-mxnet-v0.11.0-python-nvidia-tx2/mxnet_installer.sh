#!/bin/bash

UNITTESTS="N"

function usage
{
    echo "usage: mxnet_installer [-u] | [-h]]"
    echo "-u | --unittests Enable unittests to verify compatibility"
    echo "-h | --help  Print help"
}

while [ "$1" != "" ]; do
    case $1 in
        -u | --unittests )      UNITTESTS="Y"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "Starting MXNET installation on the system..."
echo "Unittests: " $UNITTESTS

set -e

sudo rm -rf mxnet/
sudo rm -rf tmp/
sudo rm -rf tests/
sudo rm -rf python/
sudo rm -rf EGG-INFO/

sudo echo "WARNING: Please enable universal repositories by modifying '/etc/apt/sources.list'"
echo 'The following lines should be uncommented in that file:'
echo 'deb http://ports.ubuntu.com/ubuntu-ports/ xenial universe'
echo 'deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial universe'
echo 'deb http://ports.ubuntu.com/ubuntu-ports/ xenial-updates universe'
echo 'deb-src http://ports.ubuntu.com/ubuntu-ports/ xenial-updates universe'

echo 'Assuming that universal repos are enabled and checking dependencies...'
sudo apt-get -y update 
sudo apt-get -y dist-upgrade
sudo apt-get install -y --reinstall liblapack3
sudo apt-get install -y --reinstall libopenblas-dev liblapack-dev
sudo apt-get install -y python-dev python-numpy python-scipy python-nose
sudo apt-get install -y python-setuptools python-pip

set +e

echo 'Dependency installation/upgrade complete. Moving forward with MXNET installation...'
tar xzvf mxnet-python.tar.gz || (echo "Unable to untar mxnet python module. Exiting..." && exit)

mv python/dist/mxnet-0.11.0-py2.7.egg mxnet.zip
unzip mxnet.zip || (echo "Unable to unzip mxnet dist. Exiting..." && exit)
rm -f mxnet.zip
ln -sf `pwd`/mxnet/libmxnet.so python/mxnet/libmxnet.so

cd python/

sudo python setup.py install || (echo "Unable to install MXNET! Stopping verification..." && exit)

echo 'MXNET installation succeeded!'
cd ../

if [ "$UNITTESTS" = "Y" ]; then
    tar xzvf mxnet-python-unittests.tar.gz || (echo "Unable to untar MXNET unittests. Exiting..." && exit)
    tar xzvf mxnet-python-gpu-tests.tar.gz || (echo "Unable to untar MXNET GPU tests. Exiting..." && exit)
    tar xzvf mxnet-python-tests-common.tar.gz || (echo "Unable to untar MXNET test commons. Exiting..." && exit)

    cd tests/python/unittest
     nosetests --verbosity=3

    if [[ $? -ne 0 ]]; then
        echo "WARNING: Some of MXNET unittests failed on this device. We strongly encourage you to get a full pass for all of the unittests before starting to use MXNET module in your GGC lambdas."
    else
        echo "CPU unittests succeeded! Starting GPU tests..."
        cd ../gpu
        nosetests --verbosity=3

    if [[ $? -ne 0 ]]; then
        echo "WARNING: Some of MXNET GPU tests failed on this device. We strongly encourage you to get a full pass for all of the tests before starting to use MXNET module in your GGC lambdas."
    else
        echo "MXNET verification succeeded!"
    fi
    cd ../../../
fi

sudo rm -rf tmp/
sudo rm -rf tests/
sudo rm -rf python/
sudo rm -rf EGG-INFO/

sudo rm -rf mxnet

set -e

echo "--------------------------------"
echo "WARNING: These MXNET binaries were built using Cuda '8.0'. We highly recommend you to have the same version on your system for compatibility reasons."

sudo tar xzf mxnet_examples.tar.gz || echo "WARNING: Failed to unpack mxnet_examples tarball!"
