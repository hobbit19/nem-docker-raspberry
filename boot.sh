#!/usr/bin/env bash
set -eu

if [ "$EUID" -ne 0 ]
  then echo "Please run as root or with sudo"
  exit
fi

if [[ $# < 1 ]]; then
  echo "Usage: $0 [pi1|pizero|pi2|pi3]"
  exit 1
fi

if [[ "$*" =~ nis || $# == 0 ]]; then
# we run the setup only if ncc is run
  ./setup.sh
fi

# Possible Builds are listed here https://docs.resin.io/runtime/resin-base-images/
case "$1" in
    "pi1" | "pizero")
        raspberryjdk="raspberry-pi-openjdk:openjdk-8-jre"
        ;;
    "pi2")
        raspberryjdk="raspberry-pi2-openjdk:openjdk-8-jre"
        ;;
    "pi3")
        raspberryjdk="raspberrypi3-openjdk:openjdk-8-jre"
        ;;
    *)
        echo "Unknown Parameter: $1 Usage: $0 [pi1|pizero|pi2|pi3]"
        exit 1
        ;;
esac

# Replace Version in Dockerfile because doesn't allow dynamic variables in FROM
sed -i 's/FROM.*/FROM resin\/'$raspberryjdk'/g' ./Dockerfile

# we rebuild and remove existing container every time.
# The benefits: upgrades are automatic after the git pull
docker build --rm=false -t mynem_image  .
docker ps -a | grep mynem_container > /dev/null && docker rm mynem_container


# determine which custom configs to mount

set -x
config_mounts=""
# nis.config-user.properties.sample  servant.config.properties.sample  supervisord.conf.sample
# - nis
config_file=$PWD/custom-configs/nis.config-user.properties
[[ -f $config_file ]] && config_mounts="$config_mounts -v $config_file:/package/nis/config-user.properties"

# - ncc
config_file=$PWD/custom-configs/ncc.config-user.properties
[[ -f $config_file ]] && config_mounts="$config_mounts -v $config_file:/package/ncc/config-user.properties"

# - servant
config_file=$PWD/custom-configs/servant.config.properties
[[ -f $config_file ]] && config_mounts="$config_mounts -v $config_file:/servant/config.properties"

# - supervisord
config_file=$PWD/custom-configs/supervisord.conf
[[ -f $config_file ]] && config_mounts="$config_mounts -v $config_file:/etc/supervisord.conf"

mkdir -p $PWD/nem/ncc
mkdir -p $PWD/nem/nis
chown -R 1000 nem


docker run --restart always --name mynem_container -v ${PWD}/nem:/home/nem/nem $config_mounts -t -d  -p 7777:7777 -p 7778:7778 -p 7880:7880 -p 7890:7890 -p 8989:8989 mynem_image
set +x


if [[ "$*" =~ nis || $# == 0 ]]; then
  echo "Starting NIS"
  ./supervisorctl.sh start nis
fi

if [[ "$*" =~ ncc ]]; then
  echo -e "\e[32mStarting NCC, which will be available at http://localhost:8989\e[39m"
  ./supervisorctl.sh start ncc
fi

echo "All done, here are the services running:"
echo -e "\e[34m"
./supervisorctl.sh status
echo -e "\e[39m"
echo
echo -e "\e[32m--------------------------------------------------------------------------------"
echo "You can control both services named 'ncc' and 'nis' with the script ./service.sh"
echo "run ./service.sh without argument to get help"
echo
echo "You can access the supervisord control shell with ./supervisorctl.sh"
echo -e "--------------------------------------------------------------------------------\e[39m"
