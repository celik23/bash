#!/bin/bash
#
# // Copyright (C) 2023 
#

# variable
default="safeAddress"
read -p "Please enter your [$default]: " safeAddress
safeAddress=${safeAddress:-$default}

default="moduleAddress"
read -p "Please enter your [$default]: " moduleAddress
moduleAddress=${moduleAddress:-$default}

default="host"
read -p "Please enter your [$default]: " host
host=${host:-$default}

# environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
source ~/.bash_profile

#🔖 -------------------------------------
# Install docker
wget -O docker-ubuntu.sh https://raw.githubusercontent.com/celik23/bash/main/oraichain/docker-ubuntu.sh && chmod +x docker-ubuntu.sh && ./docker-ubuntu.sh

default="1.93.8-next.1"
read -p "Please enter your [$default]: " tag
tag=${tag:-$default}

# Install HOPRd without Grafana (-m 2g)
docker run --pull always --restart on-failure -m 8g \
  --platform linux/x86_64 --log-driver json-file --log-opt max-size=100M --log-opt max-file=5 \
  -ti -v $HOME/.hoprd-db-dufour:/app/hoprd-db \
  -p 9091:9091/tcp -p 9091:9091/udp -p 8080:8080 -p 3001:3001 \
  -e DEBUG="hopr*" europe-west3-docker.pkg.dev/hoprassociation/docker-images/hoprd:providence \
  --network dufour --init --api \
  --identity /app/hoprd-db/.hopr-id-dufour \
  --data /app/hoprd-db \
  --password 'open-sesame-iTwnsPNg0hpagP+o6T0KOwiH9RQ0' \
  --apiHost "0.0.0.0" \
  --apiToken 'MyS3cur1tyT0ken' --healthCheck \
  --healthCheckHost "0.0.0.0" --announce \
  --safeAddress 0xf76323E048E76a7e3ceBA471ceE7e4ea3E86b00f \
  --moduleAddress 0x7B16696E07AC052af5E4E19CE01997B15bBbA751 \
  --host 65.21.49.237:9091

#👉 Backup/Recover Identity-file
# /root/.hoprd-db-monte-rosa/.hopr-id-monte-rosa
# restart hoprd.service
