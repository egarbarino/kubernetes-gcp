#!/usr/bin/python3 
# rebalance.py
import sys
import urllib.request

if len(sys.argv) < 3:
  print('rebalance.py AS_IS_SRV_1[:PORT],' + 
        'AS_IS_SRV_2[:PORT]... ' +
        'TO_BE_SRV_1[:PORT],TO_BE_SRV_2[:PORT],...')
  sys.exit(1)

# Process arguments
as_is_servers = sys.argv[1].split(',')
to_be_servers = sys.argv[2].split(',')

# Remove boilerplate from HTTP calls
def curl(url): 
  return urllib.request.urlopen(url).read().decode() 

# Copy key/vale pairs from AS IS to TO BE servers 
urls = []
for server in as_is_servers:
  keys = curl('http://' + server +
              '/allKeys').split(',')
  print(server + ': ' + str(keys))
  for key in keys: 
    print(key + '=',end='')
    value = curl('http://' + server + 
                 '/load/' + key) 
    sn = ord(key) % len(to_be_servers)
    target_server = to_be_servers[sn]
    print(value + ' ' + server + 
          '->' + target_server)
    urls.append('http://' + target_server + 
                '/save/' + key + '/' + value)
for url in urls:
  print(url,end='')
  print(' ' + curl(url))