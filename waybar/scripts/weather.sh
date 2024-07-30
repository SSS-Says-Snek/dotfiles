#/bin/bash
source ~/.config/waybar/scripts/weather.env

while true; do
  REQUEST_DATA=$(curl -s -f "https://api.weatherapi.com/v1/current.json?key=${WEATHER_API_KEY}&q=${WEATHER_LOCATION}&aqi=no")
  if ! [[ $REQUEST_DATA ]]; then
    echo "∞ °F"
  else
    TEMP_F="$(echo $REQUEST_DATA | jq '.current.temp_f') °F"
    echo $TEMP_F
  fi
  sleep 60
done
