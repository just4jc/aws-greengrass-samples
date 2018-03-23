# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import sys
import time

import numpy as np
import tensorflow as tf

class ImagenetModel(object):

    #Loads a pre-trained model locally
    #and returns an TF graph that is ready for prediction
    def __init__(self, label_file, model_file, output_layer='Model/Predictions/Reshape_1',
                 context=None,
                 label_names=None,
                 input_params=[('input', (128, 128, 224, 224))]):

        self.input_layer = input_params[0][0]
        self.input_std = input_params[0][1][0]
        self.input_mean = input_params[0][1][1]
        self.input_width = input_params[0][1][2]
        self.input_height = input_params[0][1][3]

	self.output_layer = output_layer;
        
        self.graph = load_graph(model_file)

        self.input_name = "import/" + self.input_layer
        self.output_name = "import/" + self.output_layer
        self.input_operation = self.graph.get_operation_by_name(self.input_name);
        self.output_operation = self.graph.get_operation_by_name(self.output_name);

        self.labels = load_labels(label_file)

    def predict_from_image(self, data, reshape=(224, 224), N=5):
        topN = []

        if data is None:
            return topN

        t = read_tensor_from_image(data,
                                        input_height=self.input_height,
                                        input_width=self.input_width,
                                        input_mean=self.input_mean,
                                        input_std=self.input_std)
        
        with tf.Session(graph=self.graph) as sess:
          start = time.time()
          results = sess.run(self.output_operation.outputs[0],
                            {self.input_operation.outputs[0]: t})
          end=time.time()
          
        results = np.squeeze(results)

        top_k = results.argsort()[-N:][::-1]

        print('\nEvaluation time (1-image): {:.3f}s\n'.format(end-start))

        for i in top_k:
          topN.append((self.labels[i], results[i]))
        return topN
      

def load_graph(model_file):
  graph = tf.Graph()
  graph_def = tf.GraphDef()

  with open(model_file, "rb") as f:
    graph_def.ParseFromString(f.read())
  with graph.as_default():
    tf.import_graph_def(graph_def)

  return graph

def read_tensor_from_image_file(file_name, input_height=299, input_width=299,
				input_mean=0, input_std=255):
  input_name = "file_reader"
  output_name = "normalized"
  file_reader = tf.read_file(file_name, input_name)
  if file_name.endswith(".png"):
    image_reader = tf.image.decode_png(file_reader, channels = 3,
                                       name='png_reader')
  elif file_name.endswith(".gif"):
    image_reader = tf.squeeze(tf.image.decode_gif(file_reader,
                                                  name='gif_reader'))
  elif file_name.endswith(".bmp"):
    image_reader = tf.image.decode_bmp(file_reader, name='bmp_reader')
  else:
    image_reader = tf.image.decode_jpeg(file_reader, channels = 3,
                                        name='jpeg_reader')
  float_caster = tf.cast(image_reader, tf.float32)
  dims_expander = tf.expand_dims(float_caster, 0);
  resized = tf.image.resize_bilinear(dims_expander, [input_height, input_width])
  normalized = tf.divide(tf.subtract(resized, [input_mean]), [input_std])
  sess = tf.Session()
  result = sess.run(normalized)

  return result

def read_tensor_from_image(image_data, input_height=299, input_width=299,
				input_mean=0, input_std=255):
  float_caster = tf.cast(image_data, tf.float32)
  dims_expander = tf.expand_dims(float_caster, 0);
  resized = tf.image.resize_bilinear(dims_expander, [input_height, input_width])
  normalized = tf.divide(tf.subtract(resized, [input_mean]), [input_std])
  sess = tf.Session()
  result = sess.run(normalized)

  return result

def load_labels(label_file):
  label = []
  proto_as_ascii_lines = tf.gfile.GFile(label_file).readlines()
  for l in proto_as_ascii_lines:
    label.append(l.rstrip())
  return label


