
# Info

A docker file to help you setup a nem NIS node and the NEM Community Client.

Here is a screencast showing how to start NCC:

![Imgur](http://i.imgur.com/ZBANMK4.gif?1)

Note that the first time you build the docker container, it will take more time than shown in the screencast. Subsequent runs will build faster though.

# How to run

Of course you need docker installed.

Clone this repository, get in the repo's directory.

Depending on the way you have configured docker, you might need to run these commands as root (or equivalently prefixed by sudo).

Then to start NIS only, simply run:

    ./boot.sh

to start NCC only, run:

    ./boot.sh ncc

and to start both NIS and NCC, run:

    ./boot.sh nis ncc


The first time you run it you will be prompted for a node name (required) and a boot key (optional, 
one will be generated if left empty).

This will start the NIS/NCC process(es) in the docker container named mynem_container.

To stop the container, issue:

    ./stop.sh

# Controlling the processes in the container

Services (NIS, NCC) running in the container are controlled with supervisord. You can easily control them with the script service.sh provided.

To check which services are running, issue the command:

    ./service.sh status

To stop NIS, issue the command:

    ./service.sh stop nis
    
To start NIS again, issue the command:

    ./service.sh start nis

You can restart NIS in one command:

    ./service.sh restart nis

# Importing a previously exported wallet

Before you do this, be sure you have a backup of your wallet in a safe place! Things can go wrong, and you should not use this 
if you do not have a backup of your wallets in a safe place! You've been warned and use this at your own risk!

When the container is started and running NCC, a new subdirectory is made where you can put your wallets to make them usable 
with NCC. To import an exported wallet, just unzip the exported zip file in `./nem/ncc/`. Reloading the NCC page in your browser is 
sufficient to have the wallet listed.

# Tweaking the config

If you want to tweak the config, here is some info.
The boot.sh script checks if a file config-user.properties exists, and if it doesn't, it prompts the user for information.
It then generates the file config-user.properties with a bootName and a bootKey. If you want to tweak the config of your 
node, this is the file to edit.

After the config file generation, the script builds and runs the image with these commands, naming the container mynem_container:

    sudo docker build -t mynem_image  .
    sudo docker run --name mynem_container -v ${PWD}/nem:/root/nem -t -d  -p 7890:7890 -p 8989:8989 mynem_image "$@"

This will run NIS (resp. NCC) and make it available on port 7890 (resp. 8989) of your host.
The blockchain used by NIS is saved in the nem directory, so this data is persisted across restarts of the container.

# The "nem" directory

The nem directory contains the data persisted over container runs. It contains the blockchain, but also the logs of NIS (nem/nis/logs) and NCC (nem/ncc/stderr.log).
