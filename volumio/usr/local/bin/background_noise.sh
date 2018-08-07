#!/bin/bash
#
# 20180615 RMPickering - background_noise.sh
#
# start a background noise service to ensure DAC output is available, even when Volumio is stopped
sox -c 2 -v 0 -t raw -r 48000 -b 16 -e signed-integer /dev/urandom -d

