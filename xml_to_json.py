#!/usr/bin/python

import requests
import xmltodict
import json

#Directory that script resides.
scriptDir = "/opt/scripts/plex/dvr_to_arr/"
#Set domain or IP to your plex instance including port. If using reverse proxy, do not use a trailing slash. Ensure you specify http/s.
plexUrl = "http://127.0.0.1:32400"
#plex api key
plexToken = "08d108d108d108d108d108d108d108d1"

print "Collecting DVR subscriptions from plex, this may take some time depending on how many you have."
res = requests.get(plexUrl+"/media/subscriptions?X-Plex-Token="+plexToken)
jsonString = json.dumps(xmltodict.parse(res.text, attr_prefix=''), indent=4)
f = open(scriptDir+"subscriptions.json","w+")
f.write(jsonString)
f.close()
