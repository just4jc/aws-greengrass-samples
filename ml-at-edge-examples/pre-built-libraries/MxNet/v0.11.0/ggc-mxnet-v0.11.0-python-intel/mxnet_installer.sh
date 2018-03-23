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

set +e

sudo apt-get install -y python-dev python-numpy python-scipy python-opencv python-nose

if [[ $? -ne 0 ]]; then
   echo "Failed to python dependencies. Exiting..."
   exit
else
   echo "Python dependencies are successfully installed/updated! Installing MKL library now..."
fi

./mxnet-intel-mkl-lib-installer.sh

if [[ $? -ne 0 ]]; then
   echo "MKL installation failed. Exiting..."
   exit
else
   echo "MKL installation succeeded! Installing MXNET now..."
fi

tar xzvf mxnet-python.tar.gz || (echo "Unable to untar mxnet python module. Exiting..." && exit)

mv python/dist/mxnet-0.11.0-py2.7.egg mxnet.zip 
unzip mxnet.zip || (echo "Unable to unzip mxnet dist. Exiting..." && exit)
rm -f mxnet.zip
ln -sf `pwd`/mxnet/libmxnet.so python/mxnet/libmxnet.so

cd python/

sudo python setup.py install || (echo "Unable to install MXNET! Stopping verification..." && exit)

cd ../

if [ "$UNITTESTS" = "Y" ]; then
    tar xzvf mxnet-python-unittests.tar.gz || (echo "Unable to untar MXNET unittests. Exiting..." && exit)
    tar xzvf mxnet-python-tests-common.tar.gz || (echo "Unable to untar mxnet test commons. Exiting..." && exit)

    cd tests/python/unittest
    nosetests --verbosity=3

    if [[ $? -ne 0 ]]; then
        echo "WARNING: Some of MXNET unittests failed on this device. We strongly encourage you to get a full pass for all of the unittests before starting to use MXNET module in your GGC lambdas."
    else
        echo "MXNET verification succeeded!"
    fi
    cd ../../../
fi

sudo rm -rf tmp/
sudo rm -rf tests/
sudo rm -rf python/ 
sudo rm -rf EGG-INFO/

set -e

echo "--------------------------------"
sudo tar xzf mxnet_examples.tar.gz || echo "WARNING: Failed to unpack mxnet_examples tarball!"
