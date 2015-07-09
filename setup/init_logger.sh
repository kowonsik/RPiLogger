#!/bin/bash
# Author: jeonghoon.kang@gmail.com
# Modification : kows17710@gmail.com

echo "start init_logger.sh" 

mkdir devel/Logger
cd devel/Logger/


git init

git config --global user.name 'kowonsik'

git config --global user.email 'kows17710@gmail.com'

git remote add origin 'https://github.com/kowonsik/RPiLogger.git'

git pull -u origin master

source ./setup/setup_apt.sh
source ./setup/setup_shell.sh
source ./sw/code_up.sh co

cd sw

echo ".... ending init.sh"
