# dvr_to_arr
Bash/Python script to read what recordings are scheduled in Plex DVR, search for them in Ombi and add the first request.
As it just searches and takes the first result it may sometimes be incorrect.

Requiremnets:
* plex & ombi (Sonarr & Radarr too if you wan't them downloaded but not technically required.)
* jq installed (sudo apt-get install jq)
* python version 2.7 installed (sudo apt-get install python)
* python modules "requests, xmltodict & json" (These may be part of default python install, unsure.)

Variables:
xml_to_json.py:
* scriptDir - Directory that script resides.
* plexUrl - Set domain or IP to your plex instance including port. If using reverse proxy, do not use a trailing slash. Ensure you specify http/s.
* plexToken - plex api key
dvr_to_arr.sh:
* scriptDir - Directory that script resides.
* ombiUrl - Set domain or IP to your ombi instance including port. If using reverse proxy, do not use a trailing slash. Ensure you specify http/s.
* ombiApiKey - ombi api key
* ombiUser - Set the user that should show as requesting the movie/show
