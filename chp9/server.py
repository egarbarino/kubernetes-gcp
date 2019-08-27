#!/usr/bin/python3 
# server.py
from flask import Flask
import os
import sys 

if len(sys.argv) < 3:
  print("server.py PORT DATA_DIR")
  sys.exit(1)

app     = Flask(__name__)
port    = sys.argv[1]
dataDir = sys.argv[2] + '/'
 
@app.route('/save/<key>/<word>')
def save(key, word):
  if os.path.isfile(dataDir + '_shutting_down_'):
    return "_shutting_down_", 503
  with open(dataDir + key, 'w') as f:
       f.write(word)
  return word 

@app.route('/load/<key>')
def load(key):
  if os.path.isfile(dataDir + '_shutting_down_'):
    return "_shutting_down_", 503
  try:
    with open(dataDir + key) as f:
      return f.read() 
  except FileNotFoundError:
      return "_key_not_found_" 

@app.route('/allKeys')
def allKeys():
  if os.path.isfile(dataDir + '_shutting_down_'):
    return "_shutting_down_", 503
  keys = ''.join(map(lambda x: x + ",", 
         filter(lambda f: 
                os.path.isfile(dataDir+'/'+f), 
                os.listdir(dataDir)))).rstrip(',')
  return keys 

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=port)


