#!/bin/bash
#
# // Copyright (C) 2023 
#

# Define screen colors:
RED='\e[0;31m'; CYAN='\e[1;36m'; GREEN='\e[0;32m'; BLUE='\e[1;34m'; NC='\e[0m';

# variable | input
default=${safeAddress}
read -p "Please enter your safeAddress [$default]: " safeAddress
safeAddress=${safeAddress:-$default}

default=${moduleAddress}
read -p "Please enter your moduleAddress [$default]: " moduleAddress
moduleAddress=${moduleAddress:-$default}

default=${apiToken}
read -p "Please enter your YOUR_SECURITY_TOKEN [$default]: " apiToken
apiToken=${apiToken:-$default}

default=${host}
read -p "Please enter your public-ipaddress [$default]: " host
host=${host:-$default}

echo -e "\nVerify the information below before proceeding with the installation!"
echo -e "Safe Address    : ${GREEN}$safeAddress${NC}"
echo -e "Module Address  : ${GREEN}$moduleAddress${NC}"
echo -e "Api Token       : ${GREEN}$apiToken${NC}"
echo -e "Public IPAddress: ${GREEN}$host${NC}\n"

read -p "Is the above information correct? (y/N) " choice
if [[ $choice == [Yy]* ]]; then
	# environment variables
	echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
	echo "export safeAddress=${safeAddress}" >> ~/.bash_profile
	echo "export moduleAddress=${moduleAddress}" >> ~/.bash_profile
	echo "export apiToken=${apiToken}" >> ~/.bash_profile
	echo "export host=${host}" >> ~/.bash_profile
	source ~/.bash_profile
else
    echo "Installation cancelled!"
    exit 1
fi


#🔖 -------------------------------------
# Install docker
wget -O docker-ubuntu.sh https://raw.githubusercontent.com/celik23/bash/main/oraichain/docker-ubuntu.sh && chmod +x docker-ubuntu.sh && ./docker-ubuntu.sh

# INSTALL AND RUN HOPRd (-m 8g)
docker run --pull always --restart on-failure -m 4g \
    --platform linux/x86_64 --log-driver json-file --log-opt max-size=100M --log-opt max-file=5 \
    -ti -v $HOME/.hoprd-db-dufour:/app/hoprd-db \
    -p 9091:9091/tcp -p 9091:9091/udp -p 8080:8080 -p 3001:3001 \
    -e DEBUG="hopr*" europe-west3-docker.pkg.dev/hoprassociation/docker-images/hoprd:latest \
    --network dufour --init --api \
    --identity /app/hoprd-db/.hopr-id-dufour \
    --data /app/hoprd-db \
    --password 'open-sesame-iTwnsPNg0hpagP+o6T0KOwiH9RQ0' \
    --apiHost "0.0.0.0" \
    --healthCheckHost "0.0.0.0" --announce \
    --apiToken ${apiToken} --healthCheck \
    --safeAddress ${safeAddress} \
    --moduleAddress ${moduleAddress} \
    --host ${host}:9091

#
