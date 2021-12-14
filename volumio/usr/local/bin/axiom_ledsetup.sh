#!/bin/bash

. /usr/local/bin/gpio_env.sh

#set the blue led out
echo "in" > /sys/class/gpio/gpio$PIN_POWER/direction
echo "0" > /sys/class/gpio/gpio$PIN_POWER/active_low
echo "both" > /sys/class/gpio/gpio$PIN_POWER/edge
echo "out" > /sys/class/gpio/gpio$PIN_WIFI/direction
#gpio -g mode 4 in
#gpio -g mode 4 up
#gpio -g mode 26 out

while :
do
        #read the word  in network status
        read -r status < /tmp/networkstatus

        if [ "$status" == "hotspot" ] # if it is in hotspot mode;
        then
                if [ -e /tmp/iswac ]
                then
#                        gpio -g write 26 1              #blink the blue led for 0.2 sec (WAC)
			echo "1" > /sys/class/gpio/gpio$PIN_WIFI/value
                        sleep 0.2
#                        gpio -g write 26 0
			echo "0" > /sys/class/gpio/gpio$PIN_WIFI/value
                        sleep 0.2
                else
#                        gpio -g write 26 1
			echo "1" > /sys/class/gpio/gpio$PIN_WIFI/value
                        sleep 1                                 #blink the blue led for 1 sec (Hotspot)
#                        gpio -g write 26 0
			echo "0" > /sys/class/gpio/gpio$PIN_WIFI/value
                        sleep 1
                fi

        elif [ "$status" == "ap" ]  #if wifi is connected, do those ;
        then
                #echo "0" > /sys/class/gpio/gpio500/value  #turn off the red led
#                gpio -g write 26 1   #if wifi is connected lit the blue led
		echo "1" > /sys/class/gpio/gpio$PIN_WIFI/value
        elif [ "$status" == "lan" ] #if wired connection connected, do those;
        then
                #echo "0" > /sys/class/gpio/gpio500/value #turn off the red led
#                gpio -g write 26 1              #turn on the blue led solid
		echo "1" > /sys/class/gpio/gpio$PIN_WIFI/value
        else                            #else there is a network error
#                gpio -g write 26 0              #turn off the blue led
		echo "0" > /sys/class/gpio/gpio$PIN_WIFI/value

                if [ -f /sys/class/gpio/gpio500/value ]
                then
#                        echo "1" > /sys/class/gpio/gpio500/value
			echo "1" > /sys/class/gpio/gpio$PIN_NET_ERROR/value
                        sleep 1
#                        echo "0" > /sys/class/gpio/gpio500/value        #blink the red led for 1 sec (Network error)
			echo "0" > /sys/class/gpio/gpio$PIN_NET_ERROR/value
                        sleep 1
                fi

        fi
	sleep 1
done
