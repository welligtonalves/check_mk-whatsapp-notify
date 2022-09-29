#!/bin/bash
# Push Notification (using whatsapp)
#
# Script Name   : check_mk_whatsapp-notify.sh
# Description   : Send Check_MK notifications by WhatsApp
# Author        : Welligton Analista Linux4Life
# License       : BSD 3-Clause "New" or "Revised" License
# ======================================================================================

#Variables

COMAND1="curl --user user:api --location --request -S -X POST"
COMAND2="--data "

#WhatsApp API Token, Port, Line and Destination

if [ -z ${NOTIFY_PARAMETER_1} ]; then
        echo "No WhatsApp Line. Exiting" >&2
        exit 2
else
        line="${NOTIFY_PARAMETER_1}"
fi

if [ -z ${NOTIFY_PARAMETER_2} ]; then
        echo "No WhatsApp destiny. Exiting" >&2
        exit 2
else
        destiny="${NOTIFY_PARAMETER_2}"
fi

if [ -z ${NOTIFY_PARAMETER_3} ]; then
        echo "No WhatsApp port. Exiting" >&2
        exit 2
else
        port="${NOTIFY_PARAMETER_3}"
fi

if [ -z ${NOTIFY_PARAMETER_4} ]; then
        echo "No WhatsApp key. Exiting" >&2
        exit 2
else
        key="${NOTIFY_PARAMETER_4}"
fi

# Set an appropriate emoji for the current state

if [[ ${NOTIFY_WHAT} == "SERVICE" ]]; then
        STATE="${NOTIFY_SERVICESHORTSTATE}"
else
        STATE="${NOTIFY_HOSTSHORTSTATE}"
fi
case "${STATE}" in
    OK|UP)
        EMOJI=$'\u2705' 
        ;;
    WARN)
        EMOJI=$'\u26A0\uFE0F' 
        ;;
    CRIT|DOWN)
        EMOJI=$'\u274C' 
        ;;
    UNKN)
        EMOJI=$'U+1F612' 
esac

# Create a MESSAGE variable to send to your WhatsApp

MESSAGE="${NOTIFY_HOSTNAME} (${NOTIFY_HOSTALIAS})\n\n"
MESSAGE+="${EMOJI} ${NOTIFY_WHAT} ${NOTIFY_NOTIFICATIONTYPE}\n\n"
if [[ ${NOTIFY_WHAT} == "SERVICE" ]]; then
        MESSAGE+="${NOTIFY_SERVICEDESC}\n"
        MESSAGE+="State changed from ${NOTIFY_PREVIOUSSERVICEHARDSHORTSTATE} to ${NOTIFY_SERVICESHORTSTATE}\n"
        MESSAGE+="${NOTIFY_SERVICEOUTPUT}\n"
else
        MESSAGE+="State changed from ${NOTIFY_PREVIOUSHOSTHARDSHORTSTATE} to ${NOTIFY_HOSTSHORTSTATE}\n"
        MESSAGE+="${NOTIFY_HOSTOUTPUT}\n"
fi

MESSAGE+="\nIPv4: ${NOTIFY_HOST_ADDRESS_4} \nIPv6: ${NOTIFY_HOST_ADDRESS_6}\n"
MESSAGE+="${NOTIFY_SHORTDATETIME} | ${OMD_SITE}"

# Send message to WhatsApp bot
$COMAND1 "http://api.meuaplicativo.vip:${port}/services/message_send?line=${line}&destiny=${destiny}&reference&text=${MESSAGE}" $COMAND2 "App=NetiZap%20Consumers%201.0&AccessKey=${key}"
if [ $? -ne 0 ]; then
        echo "Not able to send WhatsApp message" >&2
        exit 2
else
        exit 0
fi