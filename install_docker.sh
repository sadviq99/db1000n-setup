#!/bin/sh

sudo apt-get install -y tmux vim jq git

wget -O - https://get.docker.com/ | bash

systemctl enable docker.service
systemctl start docker.service

mkdir -p /root/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /root/.docker/cli-plugins/docker-compose
chmod +x /root/.docker/cli-plugins/docker-compose

cd /root/
git clone https://github.com/Arriven/db1000n.git

echo "15 */2 * * * cd /root/db1000n/examples/docker/ && sudo docker compose -f static-docker-compose.yml down && sudo docker compose -f static-docker-compose.yml pull && sudo docker compose -f static-docker-compose.yml up -d" >> /root/cronjob
echo "@reboot cd /root/db1000n/examples/docker/ && sudo docker compose -f static-docker-compose.yml down && sudo docker compose -f static-docker-compose.yml pull && sudo docker compose -f static-docker-compose.yml up -d" >> /root/cronjob
echo "0 0 * * * reboot" >> /root/cronjob
crontab /root/cronjob
