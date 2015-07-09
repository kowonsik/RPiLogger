#!/bin/bash
#Author: jeonghoonkang http://github.com/jeonghoonkang

if [ $1 = 'up' ]; then
    echo "... updating"
    cd
    svn up --force
    cd
    
elif [ $1 = 'co' ]; then
    echo "... installing"
    cd
    svn co http://github.com/kowonsik/RPiLogger/ devel/Logger/  
    svn co svn://125.7.128.53/danalytics --username=tinyos
    cd
else
   echo "... do notihing for code install / update"
fi


