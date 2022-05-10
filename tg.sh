#!/bin/bash

set -x

HEALTH_URL="https://itarmy.com.ua/check/"
TOTAL=$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --tail=1000 | grep -o "Total.*" | tail -n 1 | sed -e 's/[^[:digit:].-MB]/|/g' | tr -s '|' ' ')
TARGETS=$(docker compose -f /root/db1000n/examples/docker/static-docker-compose.yml logs --tail=1000 | tac | sed '/Total/,$!d;/Target/q' | tac | grep -E '(http|https)://.*' | tr -s ' ' | cut -d' ' -f4,12,13 | sed 's/http.*\/\///g' | sort -uk1,1 | sort -k2 -r | head -n 5 | sed 's/ / \`(/' | sed 's/MB/MB)\`/') 
VPN_CONFIG=$(ls /root/db1000n/openvpn/ | grep 'modified' | sed 's/.modified//g')

ATTEMPTED=$(echo $TOTAL | cut -d' ' -f 1)
SENT=$(echo $TOTAL | cut -d' ' -f 2)
RECEIVED=$(echo $TOTAL | cut -d' ' -f 3)
DATA=$(echo $TOTAL | cut -d' ' -f 4,5)

message="*Host*: \`$(hostname)\`"
message+="%0A"
message+="*Requests attempted*: \`$ATTEMPTED\`"
message+="%0A"
message+="*Requests sent*: \`$SENT\`"
message+="%0A"
message+="*Responses received*: \`$RECEIVED\`"
message+="%0A"
message+="*Data sent*: \`$DATA\`"
message+="%0A"
message+="*VPN config*: \`$VPN_CONFIG\`"
message+="%0A"
message+="*Top 5 targets by traffic*:"
message+="%0A"
message+=$TARGETS

keyboard="{\"inline_keyboard\":[[{\"text\":\"Open health report\", \"url\":\"${HEALTH_URL}\"}]]}"

curl -s --data "text=${message}" \
        --data "reply_markup=${keyboard}" \
        --data "chat_id=$TG_CHAT_ID" \
        --data "parse_mode=markdown" \
        "https://api.telegram.org/bot${TG_TOKEN}/sendMessage"