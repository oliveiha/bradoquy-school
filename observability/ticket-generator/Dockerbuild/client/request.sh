#!/bin/sh

while true
do
#   sleep_timer=$(( ( RANDOM % 10 )  + 5 ))
#   sleep $sleep_timer
   sleep 1
   curl tickets.ticket-generator.svc.cluster.local/getticket
done
