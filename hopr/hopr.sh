#!/bin/bash
#
# // Copyright (C) 2023 
#

# variable
# input
default="safeAddress"
read -p "Please enter your [$default]: " safeAddress
safeAddress=${safeAddress:-$default}

default="moduleAddress"
read -p "Please enter your [$default]: " moduleAddress
moduleAddress=${moduleAddress:-$default}

default="YOUR_SECURITY_TOKEN"
read -p "Please enter your [$default]: " apiToken
apiToken=${apiToken:-$default}

default="host-ipaddress"
read -p "Please enter your [$default]: " host
host=${host:-$default}

echo "Verify the information below before proceeding with the installation!"
echo ""
echo -e "safeAddress    : \e[1m\e[35m$safeAddress\e[0m"
echo -e "moduleAddress  : \e[1m\e[35m$moduleAddress\e[0m"
echo -e "apiToken       : \e[1m\e[35m$apiToken\e[0m"
echo -e "host           : \e[1m\e[35m$host\e[0m"
echo ""

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

# INSTALL AND RUN HOPRd (-m 4g)
docker run --pull always --restart on-failure -m 8g \
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

# end
