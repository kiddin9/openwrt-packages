#!/bin/sh

netstat -ntu | grep -v "127.0.0.1" | grep -v "::ffff:" |grep "ESTABLISHED\|CLOSED\|TIME_WAIT" | sed -e 's/_/\\_/g' | awk '{print "Protocolo: " $1 " \nOrigem: " $4 "\nDestino: " $5 "\nState: " $6 "\n" } '
