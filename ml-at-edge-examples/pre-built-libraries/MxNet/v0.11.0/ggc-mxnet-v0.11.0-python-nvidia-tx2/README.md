Greengrass Machine Learning Pre-built Libraries and Examples
================
This folder contains the machine learning pre-built libraries of MxNet and
examples. 

It contains the following directories and files:

* mxnet_installer.sh: install MxNet on the devioce.
* mxnet-python-unittests.tar.gz: unit tests for MxNet.
* mxnet-python-gpu-tests.tar.gz: unit tests for GPU
* mxnet-python.tar.gz: the MxNet binary.
* mxnet-python-tests-common.tar.gz: utils for model serving.
* examples: an example to serve models in greengrass
* mxnet_examples.tar.gz: end-to-end examples for model training and serving.

## Install

To install MxNet on the device, simply run:
  $ ./mxnet_install.sh

## Run examples

1. The examples folder contain an example of image classification. To run this,
you need to first download the MxNet squeezenet model files and place them into
the examples/greengrassObjectClassification/mxnet_models/squeezenetv1.1:
  http://data.dmlc.ml/mxnet/models/imagenet/squeezenet/squeezenet_v1.1-0000.params
  http://data.dmlc.ml/mxnet/models/imagenet/squeezenet/squeezenet_v1.1-symbol.json
  http://data.dmlc.ml/mxnet/models/imagenet/synset.txt

  Then you can run the model in examples/greengrassObjectClassification:
  $ python greengrassObjectClassification.py

2. mxnet_examples.tar.gz contains different examples to be trained in the cloud
(SageMaker) and used in edge devices. Detailed explanations can be found inside
the folder.
