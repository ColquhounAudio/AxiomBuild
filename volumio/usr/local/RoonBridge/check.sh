#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

EXITCODE=0

ESC_SEQ="\033["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"
COL_BOLD=$ESC_SEQ"1m"

echo ""
echo -e "${COL_BOLD}Checking to see if RoonBridge can run on this machine ${COL_RESET}"
echo ""

function display_check  {
    printf "    %-60s" "$1"
}

function display_ok {
    echo -e " [   ${COL_GREEN}OK${COL_RESET}   ]"
}

function display_failed {
    echo -e " [ ${COL_RED}FAILED${COL_RESET} ]"
    EXITCODE=1
}

function check_alsa {
    display_check "Checking for ALSA Libraries"
    Bridge/check_alsa >/dev/null 2>&1
    ALSA_RESULT=$?
    if [ x$ALSA_RESULT = x0 ]; then
        display_ok
    else
        display_failed
    fi
}

function check_bincompat {
    display_check "Checking for Binary Compatibility"
    Bridge/check_bincompat >/dev/null 2>&1
    BINCOMPAT_RESULT=$?
    if [ x$BINCOMPAT_RESULT = x0 ]; then
        display_ok
    else
        display_failed
    fi
}

check_bincompat
check_alsa

if [ $EXITCODE = 0 ]; then
    echo ""
    echo -e "${COL_BOLD}STATUS: ${COL_GREEN}SUCCESS${COL_RESET}"
    echo ""
else
    echo ""
    echo -e "STATUS: ${COL_RED}FAILED${COL_RESET}"
    echo ""
    echo "These issues must be addressed before RoonBridge will run on this machine."
    echo ""
    echo "For more information on how to address this, see:"
    echo ""
    echo "   http://kb.roonlabs.com/LinuxInstall"
    echo ""
fi

exit $EXITCODE
