#########
# CORES #
#########
ColorOff='\033[0m'       # Reseta as cores
Red='\033[0;91m'         # Vermelho
Green='\033[0;92m'       # Verde
Yellow='\033[0;93m'      # Amarelo
Blue='\033[0;94m'        # Azul
Purple='\033[0;95m'      # Roxo
Cyan='\033[0;96m'        # Ciano


########################
# DISPOSITIVOS PADRÕES #
########################
MULTILASER_USB_SINK="alsa_output.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.analog-stereo" # Speaker USB Headset Multilaser
MULTILASER_USB_MIC="alsa_input.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00.analog-mono" # Microfone USB Headset Multilaser


#############################
# BUSCANDO MÓDULOS DE ÁUDIO #
#############################
GREP_SINK() { # Busca os speakers (fones de ouvido) disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sinks | grep 'Nome.*PnP' | sed 's/[[:blank:]]//    g' | cut -d ':' -f 2"
}

GREP_SOURCE() { # Busca os microfones disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sources | grep 'Nome.*PnP.*analog-mono' | sed     's/[[:blank:]]//g' | cut -d ':' -f 2"
}

DELETE_OLD_CONFIG() { # Deleta as configurações default antigas
	sed -i '/set-default-*/d' /etc/pulse/default.pa
}


####################
# SHELL INTERATIVO #
####################
echo -e "${Yellow}[+] Ajuste das configurações de áudio do PulseAudio no DSLinux 4 @ Nicolas Araujo"
read -r -p "[*] Deseja fazer as alterações? [S/n]  " response
if [[ "$response" =~ ^([sS][eE][yY]|[sS])$ ]]
then
	echo
	echo -e "${Cyan}[*] Procurando módulos de áudio...${ColorOff}"
	sleep 1
	echo
	echo -e "${Cyan}[*] MÓDULOS ENCONTRADOS: ${ColorOff}"
	
	if OUT_GS=$(GREP_SINK); then # Verifica e informa os speakers reconhecidos
		echo -e "${Green}Fone: $OUT_GS ${ColorOff}"
	else
		echo -e "${Red}[!] Nenhum speaker (fone) encontrado.${ColorOff}"
	fi
	

	if OUT_GM=$(GREP_SOURCE); then # Verifica e informa os microfones reconhecidos
		echo -e "${Green}Microfone: $OUT_GM ${ColorOff}"
	else
		echo -e "${Red}[!] Nenhum microfone encontrado.${ColorOff}"
	fi
	echo
	sleep 1
	echo -e "${Cyan}[*] Apagando configurações anteriores...${ColorOff}"
	sleep 1
	sed -i '/set-default-*/d' /etc/pulse/default.pa
	echo -e "${Cyan}[*] Adicionando configurações novas...${ColorOff}"
	sleep 1
	echo "set-default-sink "$OUT_GS >> /etc/pulse/default.pa
	echo "set-default-source "$OUT_GM >> /etc/pulse/default.pa

	
	if [[ $? -eq 0 ]]; then # Verifica se as confiugrações novas foram adicionas corretamente
		echo
		echo -e "${Green}[+] Configurações finalizadas.${ColorOff}"
	else
		echo -e "${Red}[!] As configurações não puderam ser finalizadas.${ColorOff}"
	fi
	
else
	echo -e "${Red}[!] Cancelando...${ColorOff}"
fi
