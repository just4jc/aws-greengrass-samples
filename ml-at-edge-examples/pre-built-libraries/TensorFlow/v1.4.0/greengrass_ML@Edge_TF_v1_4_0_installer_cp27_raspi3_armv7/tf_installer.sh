#!/bin/bash

sudo rm -rf tmp/
sudo rm -rf tests/

sudo apt-get update
sudo apt-get -y upgrade 

set +e

sudo apt-get install -y python-numpy
sudo apt-get install -y liblapack3 || (echo "Failed to install liblapack3. Exiting..." && exit)
sudo apt-get install -y libopenblas-dev || (echo "Failed to install libopenblas. Exiting..." && exit)
sudo apt-get install -y liblapack-dev || (echo "Failed to install liblapack. Exiting..." && exit)
sudo apt-get install -y python-dev python-nose python-pip || (echo "Failed to install required python dependencies. Exiting..." && exit)

sudo apt-get install -y python-opencv zip
sudo dpkg --remove --force-depends python-numpy

sudo pip install --upgrade pip
sudo pip install wheel
sudo pip install --upgrade picamera
if [ ! -r /dev/raw1394 ]; then
	sudo ln /dev/null /dev/raw1394
fi

echo "Checking numpy..."
sudo pip install --upgrade numpy
if [[ $? -ne 0 ]]; then
  echo "Cannot install/upgrade numpy! Exiting..."
  exit
else
  echo "'numpy' check complete!"
fi

sudo pip install --upgrade scipy
if [[ $? -ne 0 ]]; then
	echo "Cannot install/upgrade scipy! Exiting..."
	exit
else
	echo "'scipy' check complete!"
fi

echo "Increasing swap partition size..."
sudo swapoff /var/swap
sudo dd if=/dev/zero of=/var/swap bs=1M count=2000
if [[ $? -eq 0 ]]; then
	sudo mkswap /var/swap
	if [[ $? -eq 0 ]]; then
		sudo swapon /var/swap
		echo "/var/swap   none    swap    defaults    0   0" | sudo tee /etc/fstab -a # Add to fstab
	fi
fi

if [[ $? -ne 0 ]]; then
	echo "WARNING: Our attempt to increase swap partition size has just failed. We will still continue with ML framework installation, however please be informed that some functionalities that require high swap size might fail. Please refer to ML framework documentation or mailing groups to get more information."
else
	echo "Swap size increased! Moving forward with ML Framework installation..."
fi 

rm -rf tmp/
rm -rf tests/

set -e

#TENSORFLOW
sudo apt --fix-broken install -y
sudo apt-get install libblas-dev libatlas-base-dev gfortran python-setuptools

sudo pip2 install tensorflow-1.4.0-cp27-none-linux_armv7l.whl

echo "--------------------------------"
echo "Done!"
echo "--------------------------------"
echo "WARNING: Tensorflow does not provide official support for 32-bit platforms. Please contact Tensorflow team for the issues you might have with any of the APIs on this system. Information contained in BUILD_DETAILS file can be used as part of the communication with them, along with the specifics of your use case."
echo "WARNING: In order for greengrasssObjectClassification example to have access to camera on this board, you might need to enable the camera peripheral using the interface provided by the following command:"
echo "----"
echo "'sudo raspi-config'"
echo "----"
echo "or refer the link below:"
echo "https://www.raspberrypi.org/documentation/configuration/camera.md"

sudo tar xzf tensorflow_examples.tar.gz || echo "WARNING: Failed to unpack tensorflow_examples tarball!"
