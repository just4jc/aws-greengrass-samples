Greengrass Machine Learning Pre-built Libraries and Examples
================
This folder contains the machine learning pre-built libraries of Tensorflow and
examples.

It contains the following directories and files:

* tf_installer.sh: install Tensorflow on the devioce.
* tensorflow-1.4.0-cp27-cp27mu-linux_aarch64.whl: binary
* examples: an example to serve models in greengrass.
* tensorflow_examples.tar.gz: end-to-end examples for model training and serving.

## Install

To install Tensorflow on the device, simply run:
  $ ./tf_install.sh

## Run examples

1. The examples folder contain an example of image classification. To run this,
you need to first download the Tensorflow mobilenet model files and place them 
into the examples/greengrassObjectClassification/tf_models/mobilenetv1. The model
files include a graph.pb and labels.txt. Instructions on how to download and
generate the model can be found in:
  https://github.com/tensorflow/models/tree/master/research/slim

  Then you can run the model in examples/greengrassObjectClassification:
  $ python greengrassObjectClassification.py

2. tensorflow_examples.tar.gz contains different examples to be trained in the
cloud (SageMaker) and used in edge devices. Detailed explanations can be found 
inside the folder.
