#!/bin/bash

sudo apt-get install python-numpy swig python-dev python-pip python-wheel -y

sudo pip install --upgrade pip

sudo pip install --upgrade tensorflow-1.4.0-cp27-cp27mu-linux_aarch64.whl

echo "Done!"
echo "--------------------------------"
echo "WARNING: Tensorflow does not provide official support for this platform. Please contact Tensorflow team for the issues you might have with any of the APIs. Information contained in BUILD_DETAILS file can be used as part of the communication with them, along with the specifics of your use case."
echo "WARNING: These Tensorflow binaries were built using Cuda '8.0' (via Jetpack 3.1). We highly recommend you to have the same version on your system for compatibility reasons."
echo "WARNING: You should consider adding the following path to your LD_LIBRARY_PATH in order to have runtime access to the symbols provided by 'libcupti' module of Cuda:"
echo "'/usr/local/cuda-8.0/lib64:/usr/local/cuda-8.0/extras/CUPTI/lib64'"

sudo tar xzf tensorflow_examples.tar.gz || echo "WARNING: Failed to unpack tensorflow_examples tarball!"
