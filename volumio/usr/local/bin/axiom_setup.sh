#!/bin/bash
#
# 20180406 RMPickering - axiom_setup.sh
#
# Configure GPIO pins and perform any other necessary startup and housekeeping tasks
. /usr/local/bin/gpio_env.sh



echo "out" > /sys/class/gpio/gpio$PIN_OUTPUT_SELECTOR_1/direction
echo "out" > /sys/class/gpio/gpio$PIN_OUTPUT_SELECTOR_2/direction
echo "0" > /sys/class/gpio/gpio$PIN_OUTPUT_SELECTOR_1/value
echo "0" > /sys/class/gpio/gpio$PIN_OUTPUT_SELECTOR_2/value

# We also need to export the additional pins from the MCP23017 and enable interrupts
# NOTE: pin $PIN_INTERNAL_LED, which is GPA0 on the MCP23017, is to be used for "Input Select"
# NOTE: pins $PIN_ANALOG_LED & 499 (GPA1 & GPA3) are for "Volume Down" and "Volume Up"
# NOTE: pin $PIN_OPTICAL_LED (GPA2) is meant for "Toggle Pause/Mute"
# Bank A - Pin 0 ($PIN_INTERNAL_LED) to 7 (503) - We only need 0, 1, 2, 3
echo "$PIN_INPUT_SELECT" > /sys/class/gpio/export
echo "$PIN_VOL_PLUS" > /sys/class/gpio/export
echo "$PIN_MUTE" > /sys/class/gpio/export
echo "$PIN_VOL_MINUS" > /sys/class/gpio/export
echo "both" > /sys/class/gpio/gpio$PIN_INPUT_SELECT/edge
echo "both" > /sys/class/gpio/gpio$PIN_VOL_PLUS/edge
echo "both" > /sys/class/gpio/gpio$PIN_MUTE/edge
echo "both" > /sys/class/gpio/gpio$PIN_VOL_MINUS/edge
# Bank B - Pin 0 (504) to 7 (511) - We only need 0, 2, 4, 6. None of these are used for input so interrupts not needed!
echo "$PIN_INTERNAL_LED" > /sys/class/gpio/export
echo "$PIN_ANALOG_LED" > /sys/class/gpio/export
echo "$PIN_OPTICAL_LED" > /sys/class/gpio/export
echo "$PIN_NET_ERROR" > /sys/class/gpio/export
echo "$PIN_WIFI" > /sys/class/gpio/export

# NOTE - In case there is a second MCP23017, it will be mapped with LOWER pin numbers!
#echo "480" > /sys/class/gpio/export 		#Note added for secondmcp
#echo "487" > /sys/class/gpio/export 		#Note added for secondmcp
#echo "both" > /sys/class/gpio/gpio480/edge  #Note added for second mcp
#echo "both" > /sys/class/gpio/gpio487/edge  #Note added for second mcp

# Some pins on the MCP23017 also need to be configured. All Bank B are output -- pins 0, 1, 2, 4 are used.
echo "out" > /sys/class/gpio/gpio$PIN_INTERNAL_LED/direction
echo "out" > /sys/class/gpio/gpio$PIN_ANALOG_LED/direction
echo "out" > /sys/class/gpio/gpio$PIN_OPTICAL_LED/direction
echo "out" > /sys/class/gpio/gpio$PIN_NET_ERROR/direction
echo "out" > /sys/class/gpio/gpio$PIN_WIFI/direction

# Bank B, pin 0 (which is mapped to pin 504) should be set high -- this indicates that the Pi itself is the source on startup!
echo "1" > /sys/class/gpio/gpio$PIN_INTERNAL_LED/value

# Don't forget to declare victory!
exit 0

