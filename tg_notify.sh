#!/bin/sh

echo "
#!/bin/bash

set -x

TG_TOKEN=\"YOUR TELEGRAM TOKEN\"
TG_CHAT_ID=\"YOUR TELEGRAM CHAT ID\"

CONFIG_URL=\$(docker-compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --tail=100 | grep -o "https://raw.*json" | uniq | tail -1)
COUNTRY=\$(docker-compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --no-log-prefix | grep  'country*' | tail -n 1 | jq -r '.country')
TOTAL=\$(docker-compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs | grep -o \"Total.*\" | tail -n 1 | sed -e 's/[^[:digit:].-MB]/|/g' | tr -s '|' ' ')


ATTEMPTED=\$(echo \$TOTAL | cut -d' ' -f 1)
SENT=\$(echo \$TOTAL | cut -d' ' -f 2)
RECEIVED=\$(echo \$TOTAL | cut -d' ' -f 3)
DATA=\$(echo \$TOTAL | cut -d' ' -f 4,5)
TARGETS=\$(curl -s \$CONFIG_URL | jq '.jobs[].args | select(.request != null) | .request.path' | sed 's/\"http.*\/\///' | sed 's/\"//' | sed 's/\/.*//g' | sort | uniq)

message=\"*Host*: \\\`\$(hostname)\\\`\"
message+=\"%0A\"
message+=\"*Requests attempted*: \\\`\$ATTEMPTED\\\`\"
message+=\"%0A\"
message+=\"*Requests sent*: \\\`\$SENT\\\`\"
message+=\"%0A\"
message+=\"*Responses received*: \\\`\$RECEIVED\\\`\"
message+=\"%0A\"
message+=\"*Data sent*: \\\`\$DATA\\\`\"
message+=\"%0A\"
message+=\"*VPN location*: \\\`\$COUNTRY\\\`\"
message+=\"%0A\"
message+=\"*Targets*:\"
message+=\"%0A\"
message+=\$TARGETS

curl -s --data \"text=\${message}\" \\
        --data \"chat_id=\$TG_CHAT_ID\" \\
        --data \"parse_mode=markdown\" \\
        \"https://api.telegram.org/bot\${TG_TOKEN}/sendMessage\"
" > /root/tg.sh

chmod u+x /root/tg.sh

echo "0 */2 * * * cd /root/ && /bin/bash tg.sh > tg.log 2>&1" >> /root/cronjob
crontab /root/cronjob
