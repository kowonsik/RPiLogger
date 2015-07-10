#!/bin/bash

CHANNEL=`hostname`
PORT="-4242"

#echo $CHANNEL$PORT
#echo CHANNEL

if [ ${CHANNEL:0:7} = LOGGER- ]
then
    echo $CHANNEL
else
    echo " ERROR: HOSTNAME should be like LOGGER-001"
    exit
fi

cd /home/pi/stalk-client

echo stalk channel:$CHANNEL
echo stalk channel:$CHANNEL$PORT

sudo screen -dmS stalk-ssh python talk.py server $CHANNEL localhost 22

sudo screen -dmS stalk_4242 python talk.py server $CHANNEL$PORT localhost 4242

cd

