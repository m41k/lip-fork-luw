#!/bin/bash
echo -e "Content-type: text/html\n\n"
server=$SERVER_NAME
sudo /usr/lib/cgi-bin/lip-tuser.sh $server
