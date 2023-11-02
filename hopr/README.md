# bash/hopr

### install hopr node
```
wget -O $HOME/hopr.sh https://raw.githubusercontent.com/celik23/bash/main/hopr/hopr.sh  && chmod +x $HOME/hopr.sh && $HOME/hopr.sh
```
### RUN HOPRd (-m 4g)
```
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
```
### Prune unused Docker objects
```
docker system prune --force
```
