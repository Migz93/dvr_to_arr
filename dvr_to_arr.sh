#!/bin/bash

#Directory that script resides.
scriptDir="/opt/scripts/plex/dvr_to_arr"
#Set domain or IP to your ombi instance including port. If using reverse proxy, do not use a trailing slash. Ensure you specify http/s.
ombiUrl="127.0.0.1:3579"
#ombi api key
ombiApiKey="08d108d108d108d108d108d108d108d1"
#Set the ombi username that should show as requesting the movie/show. Does not need to be a valid Ombi username.
ombiUser="DVR Request"

python $scriptDir/xml_to_json.py

mediaSubscriptions=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[].key")
totalSubscriptions=$(wc -l <<< "$mediaSubscriptions")
echo "$totalSubscriptions total subscriptions pulled from Plex DVR"
totalSubscriptions=$((totalSubscriptions-1))
for ((i=0;i<=totalSubscriptions;i++));
do
	subscriptions=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[$i].key")
	subscriptionType=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[$i].Directory | .type")
	if [ "$subscriptionType" == "null" ];
	then
		subscriptionType=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[$i].Video | .type")
	fi

	if [ "$subscriptionType" = "movie" ];
	then
		echo "Search ombi for movie"
		movieTitle=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[$i].Video | .title")
                movieTitle=$(echo $movieTitle | sed "s/\&/ and /g")
                movieTitle=$(/usr/bin/python -c "import urllib, sys; print urllib.quote(sys.argv[1])"  "$movieTitle")
                curl -s -X GET "$ombiUrl/api/v1/Search/movie/$movieTitle" -H  "accept: application/json" -H  "ApiKey: $ombiApiKey" -o "$scriptDir/movieTitle.json"
                movieTitleID=$(cat $scriptDir/movieTitle.json | jq -r '.[0].id')
                echo "Adding $movieTitle with TMDB ID $movieTitleID to Ombi."
                curl -X POST "$ombiUrl/api/v1/Request/movie" -H  "accept: application/json" -H  "ApiKey: $ombiApiKey" -H "ApiAlias: $ombiUser"  -H  "Content-Type: application/json-patch+json" -d "{  \"theMovieDbId\": $movieTitleID}"
                rm -rf $scriptDir/movieTitle.json
	elif [ "$subscriptionType" = "show" ];
	then
		echo "Search ombi for tv show"
		tvTitle=$(cat $scriptDir/subscriptions.json | jq -r ".[].MediaSubscription" | jq -r ".[$i].Directory | .title")
		tvTitle=$(echo $tvTitle | sed "s/\&/ and /g")
		tvTitle=$(/usr/bin/python -c "import urllib, sys; print urllib.quote(sys.argv[1])"  "$tvTitle")
		curl -s -X GET "$ombiUrl/api/v1/Search/tv/$tvTitle" -H  "accept: application/json" -H  "ApiKey: $ombiApiKey" -o "$scriptDir/tvTitle.json"
		tvTitleID=$(cat $scriptDir/tvTitle.json | jq -r '.[0].id')
		echo "Adding $tvTitle with TVDB ID $tvTitleID to Ombi."
		curl -X POST "$ombiUrl/api/v1/Request/tv" -H  "accept: application/json" -H  "ApiKey: $ombiApiKey" -H "ApiAlias: $ombiUser" -H  "Content-Type: application/json-patch+json" -d "{  \"requestAll\": true,  \"tvDbId\": $tvTitleID}"
		rm -rf $scriptDir/tvTitle.json
	fi
done
rm -rf $scriptDir/subscriptions.json
