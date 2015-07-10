#!/bin/bash
#Author: jeonghoonkang http://github.com/jeonghoonkang


if [ $1 = 'up' ]; then
    echo "... updating"
    
    #git add sect_serial_ttyUSB0.py
    git add ./
    
    git commit -m "by wonsik"
    git push -u origin master
    
elif [ $1 = 'co' ]; then
    echo "... installing"
    git pull -u origin master
    
else
   echo "... do notihing for code install / update"
fi


