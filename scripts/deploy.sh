#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument was supplied"
fi

curl -v -L -o cf.gz 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github'
tar xvfz cf.gz
chmod 755 ./cf
ls -l
./cf -v
./cf api https://api.ng.bluemix.net
./cf auth $BLUEMIX_USER $BLUEMIX_PASSWORD
./cf target -o $BLUEMIX_USER -s YoBikeMe
./cf a
./cf push $1
