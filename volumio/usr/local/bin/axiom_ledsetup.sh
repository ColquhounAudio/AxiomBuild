#!/bin/bash

#20180604-Emre Ozkan-Axiom led setup configuration script

#set the blue led out
gpio -g mode 26 out

while :
do
        #read the word  in network status
        read -r status < /tmp/networkstatus

        if [ "$status" == "hotspot" ] # if it is in hotspot mode;
        then
                if [ -e /tmp/iswac ]
                then
                        gpio -g write 26 1              #blink the blue led for 0.2 sec (WAC)
                        sleep 0.2
                        gpio -g write 26 0
                        sleep 0.2
                else
                        gpio -g write 26 1
                        sleep 1                                 #blink the blue led for 1 sec (Hotspot)
                        gpio -g write 26 0
                        sleep 1
                fi

        elif [ "$status" == "ap" ]  #if wifi is connected, do those ;
        then
                #echo "0" > /sys/class/gpio/gpio508/value  #turn off the red led
                gpio -g write 26 1   #if wifi is connected lit the blue led
        elif [ "$status" == "lan" ] #if wired connection connected, do those;
        then
                #echo "0" > /sys/class/gpio/gpio508/value #turn off the red led
                gpio -g write 26 1              #turn on the blue led solid
        else                            #else there is a network error
                gpio -g write 26 0              #turn off the blue led

                if [ -f /sys/class/gpio/gpio508/value ]
                then
                        echo "1" > /sys/class/gpio/gpio508/value
                        sleep 1
                        echo "0" > /sys/class/gpio/gpio508/value        #blink the red led for 1 sec (Network error)
                        sleep 1
                fi

        fi
        if [ -f /sys/class/gpio/gpio508/value ]
        then
                echo "0" > /sys/class/gpio/gpio508/value
        fi
done
