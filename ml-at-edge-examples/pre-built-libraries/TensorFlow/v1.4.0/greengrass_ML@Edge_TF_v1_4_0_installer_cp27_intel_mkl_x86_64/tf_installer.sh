#!/bin/bash

WITH_MKL="Y"

function usage
{
    echo "usage: tf_installer [[-u] | [-h]]"
    echo "-n | --nomkl Disable MKL support"
    echo "-h | --help  Print help"
}

while [ "$1" != "" ]; do
    case $1 in
        -n | --nomkl)     WITH_MKL="N"
			  ;;
        -h | --help )     usage
                          exit
                          ;;
        * )               usage
                          exit 1
    esac
    shift
done

sudo apt-get install python-pip python-dev
sudo pip install --upgrade pip

if [ "$WITH_MKL" = "Y" ]; then
	echo "Installing Tensorflow 1.4.0 with MKL support..."

	./intel-mkl-lib-installer.sh

	sudo pip install --upgrade tensorflow-1.4.0-cp27-cp27mu-linux_x86_64.whl
else
	echo "Installing Tensorflow 1.4.0 without MKL support..."

	sudo pip install --upgrade tensorflow-1.4.0-cp27-none-linux_x86_64.whl
fi

#sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/protobuf-3.0.0b2.post2-cp27-none-linux_x86_64.whl

echo "--------------------------------"
echo "Done!"
echo "--------------------------------"
echo "WARNING: Tensorflow does not provide official support for this platform. Please contact Tensorflow team for the issues you might have with any of the APIs. Information contained in BUILD_DETAILS file can be used as part of the communication with them, along with the specifics of your use case."

sudo tar xzf tensorflow_examples.tar.gz || echo "WARNING: Failed to unpack tensorflow_examples tarball!"
