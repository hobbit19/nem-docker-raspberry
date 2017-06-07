
# Info

A docker file to help you setup a nem NIS node and the NEM Community Client on a Raspberry Pi. It's only tested on a Rasberry Pi 3.

Note that the first time you build the docker container, it will take more time than shown in the screencast. Subsequent runs will build faster though.

# How to run

Of course you need docker installed. Install it with:

    curl -sSL https://get.docker.com | sh

If docker is installed, clone this repository and get in the repo's directory.

Depending on the way you have configured docker, you might need to run these commands as root (or equivalently prefixed by sudo).

Then to start NIS only, simply run:

    ./boot.sh

to start NCC only, run:

    ./boot.sh ncc

and to start both NIS and NCC, run:

    ./boot.sh nis ncc


The first time you run NIS you will be prompted for a node name (required) and a boot key (optional,
one will be generated if left empty).

This will start the NIS/NCC process(es) in the docker container named mynem_container.

To stop the container, issue:

    ./stop.sh

# Controlling the processes in the container

Services (NIS, NCC, Servant) running in the container are controlled with supervisord. You can easily control them with the script service.sh provided. There is a [small screencast](http://i.imgur.com/Z6U619h.gifv) illustrating the following explanations.


To check which services are running, issue the command:

    ./service.sh status

To stop NIS, issue the command:

    ./service.sh stop nis

To start NIS again, issue the command:

    ./service.sh start nis

You can restart NIS in one command:

    ./service.sh restart nis

## Servant

To run servant in the docker, you have to copy `custom-configs/servant.config.properties.sample` to `custom-configs/servant.config.properties` and edit it *before* you boot. Then "./boot.sh", wait for nis to synchronize, then `./service.sh start servant`.

# Importing a previously exported wallet

Before you do this, be sure you have a backup of your wallet in a safe place! Things can go wrong, and you should not use this if you do not have a backup of your wallets in a safe place! You've been warned and use this at your own risk!

When the container is started and running NCC, a new subdirectory is created where you can put your wallets to make them usable with NCC. To import an exported wallet, just unzip the exported zip file in `./nem/ncc/`. Reloading the NCC page in your browser is sufficient to have the wallet listed.

# Tweaking the config

The `boot.sh` script checks if a file `custom-configs/config-user.properties`
exists when running NIS, and if it doesn't, it prompts the user for
information.  It then generates the file with a bootName and a bootKey. If you
want to tweak the config of your node, this is the file to edit.

After the config file generation, the script builds and runs the image with these commands, naming the container mynem_container:

    sudo docker build -t mynem_image  .
    sudo docker run --name mynem_container -v ${PWD}/nem:/root/nem $config_mounts -t -d  -p 7777:7777 -p 7880:7880 -p 7890:7890 -p 8989:8989 mynem_image "$@"

This will run the container and make the necessary ports available on your host.
`$config_mounts` passes the necessary arguments to use the custom config file located in `custom-configs`. Currently handled files are `supervisord.conf`, 'nis.config-user.properties` and `servant.config.properties`. Here is an example to customize the supervisor config. First copy the sample config file to get started, then edit it, eg to set some services as automatically started at boot. After that stop and boot the container and the new config is applied.

```
cp custom-configs/supervisord.conf.sample custom-configs/supervisord.conf
vim custom-configs/supervisord.conf
./stop.sh
./boot.sh

```

The blockchain used by NIS is saved in the nem directory, so this data is persisted across restarts of the container. The [database of the blockchain](http://bob.nem.ninja/ "Nem Repository") can be downloaded to speed up the sync process. The database should be placed in folder `./nem/nis/data`.

# The "nem" directory

The nem directory contains the data persisted over container runs. It contains the blockchain, but also the logs of NIS (nem/nis/logs) and NCC (nem/ncc/stderr.log).
