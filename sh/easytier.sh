
#!/bin/bash

IP=$(ip addr show | grep -E 'inet [0-9]' | awk '{print $2}' | awk -F '/' '{print $1}'| grep -v '127.0.0.1' )
echo "IP:$IP"


"HOME/BIN_PATH/easytier/easytier" --hostname host  -i $IP  -l  ws://0.0.0.0:1102  --network-secret SECERT_EASYTIER --no-tun #ws

