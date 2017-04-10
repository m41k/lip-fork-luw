#!/bin/bash

#example
#iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 81 -j DNAT --to 10.0.3.86:80

/sbin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $1 -j DNAT --to $2:$3
