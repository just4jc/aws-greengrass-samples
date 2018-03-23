import io
import os
import time
import cv2
import numpy as np

import platform


class ImagenetModel(object):

    #Loads a pre-trained model locally or from an external URL
    #and returns a graph that is ready for prediction
    def __init__(self, model_path, framework, synset_path, network,
                 output_layer=None, context='CPU',
                 input_params=[('data', (1, 3, 224, 224))], label_names=['prob_label']):

        if framework == 'MXNET':
            import load_mxnet_model as load_model
        elif framework == 'TF':
            import load_tf_model as load_model
        else:
            raise ImportError("Unsupported framework type: " + framework)
        
        self.mod = load_model.ImagenetModel(model_path + synset_path, model_path + network, output_layer, context, label_names, input_params)

        if platform.machine() == "armv7l": # RaspBerry Pi
            import picamera
            self.camera = picamera.PiCamera()
        if platform.machine() == "aarch64": # Nvidia Jetson TX
            self.camera = cv2.VideoCapture("nvcamerasrc ! video/x-raw(memory:NVMM)," +\
                                           "width=(int)800,height=(int)480,format=(string)I420," +\
                                           "framerate=(fraction)30/1 ! nvvidconv flip-method=2 !" +\
                                           "video/x-raw, format=(string)I420 ! videoconvert !" +\
                                           "video/x-raw, format=(string)BGR ! appsink")
        if platform.machine() == "x86_64": # Intel benson
            import awscam
            self.camera = awscam

    def predict_from_image(self, cvimage, reshape=(224, 224), N=5):      
        return self.mod.predict_from_image(cvimage, reshape, N)

    #Captures an image from the PiCamera, then sends it for prediction
    def predict_from_cam(self, reshape=(224, 224), N=5):
        if platform.machine() == "armv7l": # RaspBerry Pi
            stream = io.BytesIO()
            self.camera.start_preview()
            time.sleep(2)
            self.camera.capture(stream, format='jpeg')
            # Construct a numpy array from the stream
            data = np.fromstring(stream.getvalue(), dtype=np.uint8)
            # "Decode" the image from the array, preserving colour
            cvimage = cv2.imdecode(data, 1)

        if platform.machine() == "aarch64": # Nvidia Jetson TX
            if self.camera.isOpened():
                ret, cvimage = self.camera.read()
                cv2.destroyAllWindows()
            else:
                raise RuntimeError("Cannot open the camera")

        if platform.machine() == "x86_64": # Intel benson
            ret, cvimage = self.camera.getLastFrame()
            if ret == False:
                raise RuntimeError("Failed to get frame from the stream")

        return self.predict_from_image(cvimage, reshape, N)
