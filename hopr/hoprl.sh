#!/bin/bash
#
# // Copyright (C) 2023 
#

# environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
source ~/.bash_profile

# Install docker
wget -O docker-ubuntu.sh https://github.com/celik23/bash/raw/main/docker-ubuntu.sh && chmod +x docker-ubuntu.sh && ./docker-ubuntu.sh

#👉 Backup/Recover Identity-file
#/root/.hoprd-db-monte-rosa/.hopr-id-monte-rosa

# Install HOPRd without Grafana (-m 2g)
tag=1.93.8-next.1
docker run --name hopr_net \
  --pull always --restart on-failure -m 4g \
  --log-driver json-file --log-opt max-size=100M --log-opt max-file=5 \
  -ti -v $HOME/.hoprd-db-monte-rosa:/app/hoprd-db \
  -p 9091:9091/tcp -p 9091:9091/udp -p 8080:8080 -p 3001:3001 \
  -e DEBUG="hopr*" gcr.io/hoprassociation/hoprd:${tag} \
  --environment monte_rosa --init --api \
  --identity /app/hoprd-db/.hopr-id-monte-rosa \
  --data /app/hoprd-db \
  --password 'open-sesame-iTwnsPNg0hpagP+o6T0KOwiH9RQ0' \
  --apiHost "0.0.0.0" --apiToken 'MyT0ken@' \
  --healthCheck --healthCheckHost "0.0.0.0"

