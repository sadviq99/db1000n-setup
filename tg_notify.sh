#!/bin/sh

echo "
#!/bin/bash

set -x

TG_TOKEN=\"YOUR TELEGRAM TOKEN\"
TG_CHAT_ID=\"YOUR TELEGRAM CHAT ID\"

CONFIG_URL=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --tail=100 | grep -o \"https://raw.*json\" | uniq | tail -1)

message=\"Host: \$(hostname)\"
message+=\"%0A\"
message+=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs | grep -o \"Current country: [.a-zA-Z]*\" | tr -s ' ' | tail -n 1)
message+=\"%0A\"
message+=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs | grep -o \"Generated.*|\" | sed 's/ ] /: /' | sed 's/ |//' | tr -s ' ' | tail -n 1)
message+=\"%0A\"
message+=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs | grep -o \"Received.*|\" | sed 's/ ] /: /' | sed 's/ |//' | tr -s ' ' | tail -n 1)
message+=\"%0A\"
message+=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs | grep -o \"Response rate.*\" | sed 's/ ] /: /' | tr -s ' ' | tail -n 1)
message+=\"%0A\"
message+=\"Targets:\"
message+=\"%0A\"
message+=\$(curl -s \$CONFIG_URL | jq '.jobs[].args | select(.request != null) | .request.path' | sed 's/\"http.*\/\///' | sed 's/\"//' | sed 's/\/.*//g' | sort | uniq)


curl -s --data \"text=\${message}\" \
        --data \"chat_id=\$TG_CHAT_ID\" \
        \"https://api.telegram.org/bot\${TG_TOKEN}/sendMessage\"
" >> /root/tg.sh

chmod u+x /root/tg.sh

echo "0 */2 * * * cd /root/ && /bin/bash tg.sh > tg.log 2>&1" >> /root/cronjob
crontab /root/cronjob
