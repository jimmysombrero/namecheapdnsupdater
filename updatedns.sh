#!/bin/bash

FILE=/tmp/wanip
WANIP=""
DOMAIN=""
PASSWORD=""

function update_dyn_dns() {
  echo "Updating DNS Entry" | logger -i -p daemon.info
  
  BASERESULTXML=`curl -s "https://dynamicdns.park-your-domain.com/update?host=@&domain=$DOMAIN&password=$PASSWORD&ip=$CURRENTIP"`
  WWWRESULTXML=`curl -s "https://dynamicdns.park-your-domain.com/update?host=www&domain=$DOMAIN&password=$PASSWORD&ip=$CURRENTIP"`

  BASEURLERRORCOUNT=`echo "$BASERESULTXML" | xmlstarlet sel -t -m "//ErrCount" -v .`
  WWWURLERRORCOUNT=`echo "$WWWRESULTXML" | xmlstarlet sel -t -m "//ErrCount" -v .`

  if [ "$BASEURLERRORCOUNT" > 0 ]; then
    DNSERROR=`echo "$BASERESULTXML" | xmlstarlet sel -t -m "//ResponseString" -v .`
    echo "@ URL - $DNSERROR" | logger -i -p daemon.error
  fi


  if [ "$WWWURLERRORCOUNT" > 0 ]; then
    DNSERROR=`echo "$WWWRESULTXML" | xmlstarlet sel -t -m "//ResponseString" -v .`
    echo "WWW URL - $DNSERROR" | logger -i -p daemon.error
  fi
}

while true; do
  CURRENTIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"

  if [ -f "$FILE" ]; then
    WANIP=`cat /tmp/wanip`
  else
    WANIP="$CURRENTIP"
    echo "$CURRENTIP" > /tmp/wanip
  fi

  if [ "$CURRENTIP" != "$WANIP" ]; then
	  echo "$CURRENTIP"
	  echo "$WANIP"
    update_dyn_dns
  fi

  sleep 30m
done
