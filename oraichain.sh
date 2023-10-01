#🕌 andromeda
🔑 sudo su | 🔑 sudo -i passwd root
#💰 18-07-2023 t/m heden €15.85server + €0.61IPv4 = €16.46/pm Hetzner:CPX31-4VCPU-8GB-160GB
#🪢 IPV4: 95.217.128.93
#🪢 IPV6: 2a01:4f9:c012:7bda::1/64
🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#➣ Andromeda install date: 18-07-2023
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# environment variables
echo 'export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[1;34m\]\h:\[\e[1;36m\]\w\[\e[1;35m\]\$\[\e[0m\] "' >> ~/.bash_profile
echo 'export MONIKER="Andromeda"' >> ~/.bash_profile
echo 'export CHAIN_ID=Oraichain' >> ~/.bash_profile
echo 'export PASS="B!N453han@"' >> ~/.bash_profile
echo 'export VERSION=v0.41.4' >> ~/.bash_profile
source ~/.bash_profile
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#👉 1. firewall settup
sudo apt update -y
sudo apt install ufw -y
sudo ufw allow 22,443,26656:26657/tcp
sudo ufw --force enable 
sudo ufw status verbose
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
# https://github.com/celik23/bash
wget -O $HOME/oraichain.sh https://github.com/celik23/bash/raw/main/oraichain.sh && chmod +x $HOME/oraichain.sh && $HOME/oraichain.sh

# Input:
➣ 'Moniker name :' Andromeda
➣ 'Snapshot name:' Oraichain_13715321.tar.lz4
🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🏀 Go docker container manual install 🏀

#Enter keyring passphrase: <keypass>
- name: Andromeda
  type: local
  address: orai1425a2jysn9lkacvuwmde89vxqlpxa0xd2p28xt
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"Atv636/+gajhJ/Fa1aJld1F4j7Zz5HfdMe9qMSuPwOP5"}'
  mnemonic: ""
  Operator-address: oraivaloper1425a2jysn9lkacvuwmde89vxqlpxa0xdrt3wdv
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🛑 screen -ls <list-session> | screen -S <new-session-name> | screen -r <session-name> | screen -d -r 27863 <deatach>
screen -S home
docker-compose restart orai && docker-compose exec -d orai bash -c 'oraivisor start'
docker-compose restart orai && docker-compose exec -d orai bash -c 'oraivisor start --p2p.pex false --p2p.persistent_peers "e6fa2f222236a9ca5e10b238de87eb12497a649c@167.99.119.182:26656,911b290c59a4d3248534b53bdbc8dd4615bb5870@167.99.119.182:26656,35c1f999d67de56736b412a1325370a8e2fdb34a@5.189.169.99:26656,5ad3b29bf56b9ba95c67f282aa281b6f0903e921@64.225.53.108:26656"'
#✋ 🍺🍺🍺 WAIT UNTIL YOUR NODE IS SYNCHRONIZED 🍺🍺🍺
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#👉 Recover node information
#🛑 /root/orai/.oraid/config/priv_validator_key.json
#🛑 /root/orai/.oraid/config/node_key.json
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#                   👆 OR 👇
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🚀 Create validator transaction (inside of the container)
#🚀 make 2orai over to the Vallet
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
docker-compose exec orai bash
wget -O /usr/bin/fn https://raw.githubusercontent.com/oraichain/oraichain-static-files/master/fn.sh && chmod +x /usr/bin/fn && fn createValidator
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
#🛑 Edit validators
oraid tx staking edit-validator \
--chain-id $CHAIN_ID \
--new-moniker $MONIKER \
--details "In the ever-expanding universe of blockchain technology, Andromeda emerges as a guiding star, illuminating the path towards secure and decentralized consensus. As a validator node, Andromeda plays a pivotal role in ensuring the integrity and reliability of blockchain projects." \
--website "-" \
--from $USER \
--fees 250orai \
--commission-rate=0.03 \
-y
#🔖 〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️〰️
