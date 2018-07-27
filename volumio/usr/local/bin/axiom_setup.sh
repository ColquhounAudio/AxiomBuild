#!/bin/bash
#
# 20180406 RMPickering - axiom_setup.sh
#
# Configure GPIO pins and perform any other necessary startup and housekeeping tasks
gpio -g mode 5 out
gpio -g mode 6 out
gpio -g write 5 0
gpio -g write 6 0

# We also need to export the additional pins from the MCP23017 and enable interrupts
# NOTE: pin 496, which is GPA0 on the MCP23017, is to be used for "Input Select"
# NOTE: pins 497 & 499 (GPA1 & GPA3) are for "Volume Down" and "Volume Up"
# NOTE: pin 498 (GPA2) is meant for "Toggle Pause/Mute"
# Bank A - Pin 0 (496) to 7 (503) - We only need 0, 1, 2, 3
echo "496" > /sys/class/gpio/export
echo "497" > /sys/class/gpio/export
echo "498" > /sys/class/gpio/export
echo "499" > /sys/class/gpio/export
echo "both" > /sys/class/gpio/gpio496/edge
echo "both" > /sys/class/gpio/gpio497/edge
echo "both" > /sys/class/gpio/gpio498/edge
echo "both" > /sys/class/gpio/gpio499/edge
# Bank B - Pin 0 (504) to 7 (511) - We only need 0, 2, 4, 6. None of these are used for input so interrupts not needed!
echo "504" > /sys/class/gpio/export
echo "505" > /sys/class/gpio/export
echo "506" > /sys/class/gpio/export
echo "507" > /sys/class/gpio/export
echo "508" > /sys/class/gpio/export
echo "509" > /sys/class/gpio/export
echo "510" > /sys/class/gpio/export

# NOTE - In case there is a second MCP23017, it will be mapped with LOWER pin numbers!
#echo "480" > /sys/class/gpio/export 		#Note added for secondmcp
#echo "487" > /sys/class/gpio/export 		#Note added for secondmcp
#echo "both" > /sys/class/gpio/gpio480/edge  #Note added for second mcp
#echo "both" > /sys/class/gpio/gpio487/edge  #Note added for second mcp

# Some pins on the MCP23017 also need to be configured. All Bank B are output -- pins 0, 1, 2, 4 are used.
echo "out" > /sys/class/gpio/gpio504/direction
echo "out" > /sys/class/gpio/gpio505/direction
echo "out" > /sys/class/gpio/gpio506/direction
echo "out" > /sys/class/gpio/gpio507/direction
echo "out" > /sys/class/gpio/gpio508/direction
echo "out" > /sys/class/gpio/gpio509/direction
echo "out" > /sys/class/gpio/gpio510/direction

# Bank B, pin 0 (which is mapped to pin 504) should be set high -- this indicates that the Pi itself is the source on startup!
echo "1" > /sys/class/gpio/gpio504/value

# Don't forget to declare victory!
exit 0

