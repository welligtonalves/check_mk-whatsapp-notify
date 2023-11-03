#!/bin/bash
# Push Notification (using WhatsApp)
#
# Script Name   : check_mk_whatsapp-notify.sh
# Description   : Send Check_MK notifications via WhatsApp
# Author        : Welligton Analista Linux4Life
# License       : BSD 3-Clause "New" or "Revised" License
# ======================================================================================

# Variáveis

COMMAND="curl --user user:api --location --request -S -X POST"

# Token da API do WhatsApp, Porta, Linha e Destino

if [ -z "${NOTIFY_PARAMETER_1}" ]; then
    echo "Nenhuma linha do WhatsApp definida. Saindo." >&2
    exit 2
else
    line="${NOTIFY_PARAMETER_1}"
fi

if [ -z "${NOTIFY_PARAMETER_2}" ]; then
    echo "Nenhum destino do WhatsApp definido. Saindo." >&2
    exit 2
else
    destiny="${NOTIFY_PARAMETER_2}"
fi

if [ -z "${NOTIFY_PARAMETER_3}" ]; then
    echo "Nenhuma porta do WhatsApp definida. Saindo." >&2
    exit 2
else
    port="${NOTIFY_PARAMETER_3}"
fi

if [ -z "${NOTIFY_PARAMETER_4}" ]; then
    echo "Nenhuma chave do WhatsApp definida. Saindo." >&2
    exit 2
else
    key="${NOTIFY_PARAMETER_4}"
fi

# Defina um emoji apropriado para o estado atual

if [[ "${NOTIFY_WHAT}" == "SERVICE" ]]; then
    STATE="${NOTIFY_SERVICESHORTSTATE}"
else
    STATE="${NOTIFY_HOSTSHORTSTATE}"
fi

case "${STATE}" in
    OK|UP)
        EMOJI=$'\u2705'  # Emoji de marca de seleção verde
        ;;
    WARN)
        EMOJI=$'\u26A0\uFE0F'  # Emoji de aviso
        ;;
    CRIT|DOWN)
        EMOJI=$'\u274C'  # Emoji de marca de seleção vermelha
        ;;
    UNKN)
        EMOJI=$'\u2753'  # Emoji de ponto de interrogação
        ;;
esac

# Variável MESSAGE para enviar ao seu WhatsApp

MESSAGE="${NOTIFY_HOSTNAME} (${NOTIFY_HOSTALIAS})\n\n"
MESSAGE+="${EMOJI} ${NOTIFY_WHAT} ${NOTIFY_NOTIFICATIONTYPE}\n\n"

if [[ "${NOTIFY_WHAT}" == "SERVICE" ]]; then
    MESSAGE+="${NOTIFY_SERVICEDESC}\n"
    MESSAGE+="Estado alterado de ${NOTIFY_PREVIOUSSERVICEHARDSHORTSTATE} para ${NOTIFY_SERVICESHORTSTATE}\n"
    MESSAGE+="${NOTIFY_SERVICEOUTPUT}\n"
else
    MESSAGE+="Estado alterado de ${NOTIFY_PREVIOUSHOSTHARDSHORTSTATE} para ${NOTIFY_HOSTSHORTSTATE}\n"
    MESSAGE+="${NOTIFY_HOSTOUTPUT}\n"
fi

MESSAGE+="\nIPv4: ${NOTIFY_HOST_ADDRESS_4} \nIPv6: ${NOTIFY_HOST_ADDRESS_6}\n"
MESSAGE+="${NOTIFY_SHORTDATETIME} | ${OMD_SITE}"

# Envie a mensagem para o bot do WhatsApp

$COMMAND "http://api.meuaplicativo.vip:${port}/services/message_send?line=${line}&destiny=${destiny}&reference&text=${MESSAGE}" --data "App=NetiZap%20Consumers%201.0&AccessKey=${key}"

if [ $? -ne 0 ]; then
    echo "Não foi possível enviar a mensagem do WhatsApp" >&2
    exit 2
else
    exit 0
fi
