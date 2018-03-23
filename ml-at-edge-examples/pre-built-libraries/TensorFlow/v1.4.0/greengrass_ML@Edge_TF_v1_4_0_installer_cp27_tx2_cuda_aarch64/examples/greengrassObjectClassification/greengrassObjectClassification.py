#
# Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#

# greengrassObjectClassification.py
# Demonstrates inference at edge using MXNET or TensorFlow, and Greengrass 
# core sdk. This function will continuously retrieve the predictions from the 
# ML framework and send them to the topic 'hello/world'.
#
# The function will sleep for three seconds, then repeat.  Since the function is
# long-lived it will run forever when deployed to a Greengrass core.  The handler
# will NOT be invoked in our example since we are executing an infinite loop.

import sys
import time
import greengrasssdk
import platform
import os
from threading import Timer
import load_model

client = greengrasssdk.client('iot-data')

#model_path = '/greengrass-machine-learning/mxnet/squeezenet/'
#model_path = './mxnet_models/squeezenetv1.1/'
#global_model = load_model.ImagenetModel(model_path, 'MXNET', 'synset.txt', 'squeezenet_v1.1')

#model_path = '/greengrass-machine-learning/tf/mobilenet/'
model_path = './tf_models/mobilenetv1/'
global_model = load_model.ImagenetModel(model_path, 'TF', 'labels.txt', 'graph.pb', 'MobilenetV1/Predictions/Reshape_1', 'CPU', [('input', (128, 128, 224, 224))])


# When deployed to a Greengrass core, this code will be executed immediately
# as a long-lived lambda function.  The code will enter the infinite while loop
# below.
def greengrass_object_classification_run():
    if global_model is not None:
        try:
            predictions = global_model.predict_from_cam()
	    print predictions
            #publish predictions
            client.publish(topic='hello/world', payload='New Prediction: {}'.format(str(predictions)))
        except Exception as ex:
            e = sys.exc_info()[0]
            print("Exception occured during prediction: %s" % e)
            print("Ex: %s" % ex)

    # Asynchronously schedule this function to be run again in 1 seconds
    Timer(1, greengrass_object_classification_run).start()


# Execute the function above
greengrass_object_classification_run()


# This is a dummy handler and will not be invoked
# Instead the code above will be executed in an infinite loop for our example
def function_handler(event, context):
    return
