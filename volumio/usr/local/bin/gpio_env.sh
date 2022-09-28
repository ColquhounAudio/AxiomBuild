#!/bin/bash


for i in /sys/class/gpio/gpiochip*; do
	echo "Scanning $i"
	chip_label=$(< $i/label)
	declare -i chip_base=$(< $i/base)
	case $chip_label in
		*"mcp23017"*)
			echo "Found MCP in $i ($chip_label} with base $chip_base"
			export PIN_INPUT_SELECT=$(($chip_base + 0))
			export PIN_VOL_PLUS=$(($chip_base + 3))
			export PIN_MUTE=$(($chip_base + 2))
			export PIN_VOL_MINUS=$(($chip_base + 1))
			export PIN_INTERNAL_LED=$(($chip_base + 8))
			export PIN_ANALOG_LED=$(($chip_base + 9))
			export PIN_OPTICAL_LED=$(($chip_base + 10))
			export PIN_NET_ERROR=$(($chip_base + 12))
		;;
		*"pinctrl"*)
			echo "Found BCM in $i ($chip_label} with base $chip_base"
			export PIN_POWER=$(($chip_base + 4))
			export PIN_OUTPUT_SELECTOR_1=$(($chip_base + 5))
			export PIN_OUTPUT_SELECTOR_2=$(($chip_base + 6))
			export PIN_WIFI=$(($chip_base + 26))
		;;
		*"gpio2"*)
			echo "Found RK3399 BANK2 in $i ($chip_label} with base $chip_base"
			export PIN_POWER=$(($chip_base + 11))
			export PIN_OUTPUT_SELECTOR_1=$(($chip_base + 10))
			export PIN_OUTPUT_SELECTOR_2=$(($chip_base + 9))
		;;
		*"gpio4"*)
			echo "Found RK3399 BANK4 in $i ($chip_label} with base $chip_base"
			export PIN_WIFI=$(($chip_base + 30))
		;;


	esac
done
