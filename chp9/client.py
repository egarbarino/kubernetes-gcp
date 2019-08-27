#!/usr/bin/python3 
import string
import time
import sys 
import urllib.request
import urllib.error
import datetime

if len(sys.argv) < 2:
  print('client.py SRV_1[:PORT],SRV_2[:PORT],... [readonly]')
  sys.exit(1)

# Process input arguments
servers  = sys.argv[1].split(',')
readonly = (True if len(sys.argv) >= 3 
            and sys.argv[2] == 'readonly' else False)

# Remove boilerplate from HTTP calls
def curl(url): 
  return urllib.request.urlopen(url).read().decode() 

# Print alphabet and selected server for each letter
sn = len(servers)
print(' ' * 20 + string.ascii_lowercase)
print(' ' * 20 + '-' * 26)
print(' ' * 20 + ''.join(map(lambda c: str(ord(c) % sn),
                             string.ascii_lowercase)))
print(' ' * 20 + '-' * 26)

# Iterate through the alphabet repeatedly 
while True:
  print(str(datetime.datetime.now())[:19] + ' ', end='')
  hits = 0
  for c in string.ascii_lowercase:
    server = servers[ord(c) % sn]
    try:
      r = curl('http://' + server + '/load/' + c)
      # Key found and value match
      if r == c:
        hits = hits + 1
        print('h',end='') 
      # Key not found  
      elif r == '_key_not_found_':
        if readonly:
          print('m',end='')
        else:
          # Save Key/Value (not read only)
          r = curl('http://' + server + '/save/' + c + '/' + c)
          print('w',end='')
      # Value mismatch
      else:  
        print('x',end='')
    except urllib.error.HTTPError as e:
          print(str(e.getcode())[0],end='')
    except urllib.error.URLError as e:
          print('.',end='')
  print(' | hits = {} ({:.0f}%)'
        .format(hits,hits/0.26))
  time.sleep(2) 