#!/bin/sh

echo "
#!/bin/bash

set -x

TG_TOKEN=\"YOUR TELEGRAM TOKEN\"
TG_CHAT_ID=\"YOUR TELEGRAM CHAT ID\"

TARGETS=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --tail=1000 | grep 'stats' | grep 'target.*://.*' | cut -d '|' -f 2 | jq -r '. | \"\(.target) \`(\(.requests_sent)/\(.responses_received), \(.bytes_sent/1000000)MB)\`\"' | sed 's/.*\/\///' | awk -F' ' '!_[\$1]++' | sed -E 's/([0-9]+\.[0-9]{1,2})[^ ]*MB/\1MB/g' | sort -n -r -k3)
COUNTRY=\$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --no-log-prefix | grep  'country*' | tail -n 1 | jq -r '.country')

message=\"*Host*: \\\`\$(hostname)\\\`\"
message+=\"%0A\"
message+=\"*VPN location*: \\\`\$COUNTRY\\\`\"
message+=\"%0A\"
message+=\"*Targets*:\"
message+=\"%0A\"
message+=\$TARGETS

curl -s --data \"text=\${message}\" \
        --data \"chat_id=\$TG_CHAT_ID\" \
        --data \"parse_mode=markdown\" \
        \"https://api.telegram.org/bot\${TG_TOKEN}/sendMessage\"
" > /root/tg.sh

chmod u+x /root/tg.sh

echo "0 */2 * * * cd /root/ && /bin/bash tg.sh > tg.log 2>&1" >> /root/cronjob
crontab /root/cronjob
