#!/bin/bash

USER=y60
CLIENT=10.1.3.105
PULL=0
MAKE=0
for i in $*
do
    case $i in
        pull)
            PULL=1
            ;;
        make)
            MAKE=1
            ;;
        client=*)
            CLIENT=${i##*=}
            ;;
        *)
        #unknown
       ;;
   esac
done

if [ $PULL -eq 1 ]; then
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/asl && git pull"
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/y60src && git pull"
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/watchdog && git pull"
fi

if [ $MAKE -eq 1 ]; then
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/asl/_builds/release && cmake ../../ && make && make install"
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/y60src/_builds/release && cmake ../../ && make && make install"
    ssh ${USER}@${CLIENT} -2 -x "cd /home/y60/watchdog/_builds/release && cmake ../../ && make && make install"
fi

ssh ${USER}@${CLIENT} -2 -x "tar -C '/home/y60/install/' -czvf 'y60.tar.gz' ./asl/lib/ ./asl/bin/ ./y60/lib/ ./y60/bin/ ./watchdog/bin/"
scp ${USER}@${CLIENT}:"/home/y60/y60.tar.gz" .
