#!/bin/bash

ip_target=
pass_target=
user_target=
container=

sleep 3
# ping, wait til on. If ping ok, try ssh
while ! ping -c1 $ip_target &>/dev/null; do
        echo "Not yet..."
done

echo "Remote ready!"

# ssh to host
# check msr module -> ls /dev/cpu/0/msr should exist
# start dockerd daemon
# sshpass -p $pass_target ssh -t $user_target@$ip_target "echo $pass_target | sudo -S dockerd 2>&1 > /dev/null &"
# docker start $container
sshpass -p $pass_target ssh -t $user_target@$ip_target docker start $container

# sudo plundervolt/utils/set_stat_freq.sh 16
sshpass -p $pass_target ssh -t $user_target@$ip_target "echo $pass_target | sudo -S plundervolt/utils/set_stat_freq.sh 16"

# run the mul program -or its variants - in container
#   /data/mul/mul.native.exe -i 1000 -1 ba8ed449 -2 b2f7a876 -z fixed -x fixed -t 4 -M
# sshpass -p $pass_target ssh -t $user_target@$ip_target "docker exec -e SCONE_ALPINE=1 -e SCONE_VERSION=1 -it $container '/data/mul/mul.native.exe -i 1000 -1 ba8ed449 -2 b2f7a876 -z fixed -x fixed -t 4 -M >  &'"
# sshpass -p $pass_target ssh -t $user_target@$ip_target "docker exec -e SCONE_ALPINE=1 -e SCONE_VERSION=1 -d $container /data/run.sh"

# put some delay
sleep 3

# sudo ~/undervolt/run.sh (blocking)
# sshpass -p $pass_target ssh -t -f $user_target@$ip_target  "echo $pass_target | sudo -S nohup /home/$user_target/undervolt/run.sh > /dev/null 2>&1 &"
# if ping not responing -> need restart

# restart

# what if "failed succesfully" (Pun intended)?
