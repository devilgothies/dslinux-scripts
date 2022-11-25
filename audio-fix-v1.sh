#  ___      _ _                _
# |   \ ___| | |_ __ _ ____  _| |
# | |) / -_) |  _/ _` (_-< || | |
# |___/\___|_|\__\__,_/__/\_,_|_|
#
# Script para ajustar os speakers/headsets usados nas lojas, nas configurações default do PulseAudio. @ Utilização no DSLinux 4
# Cheque o repositório oficial -> https://gitlab.deltasul.com.br/NicolasAraujo/dslinux-scripts
# Desenvolvido por Nicolas Araujo

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


###########
# FUNÇÕES #
###########
GREP_SINK() { # Busca os speakers (fones de ouvido) disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sinks | grep -E 'Nome.*PnP|Nome.*EPKO' | sed 's/[[:blank:]]//g' | cut -d ':' -f 2"
}

GREP_SOURCE() { # Busca os microfones disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sources | grep -E 'Nome.*PnP.*monitor|Nome.*EPKO.*monitor' | sed 's/[[:blank:]]//g' | cut -d ':' -f 2"
}

DELETE_OLD_CONFIG() { # Deleta as configurações default antigas
	sed -i '/set-default-*/d' /etc/pulse/default.pa
}

ADD_NEW_CONFIG() {
	echo "set-default-sink "$OUT_GS >> /etc/pulse/default.pa
	echo "set-default-source "$OUT_GM >> /etc/pulse/default.pa
}

####################
# SHELL INTERATIVO #
####################
echo -e "${Yellow}[+] Ajuste das configurações de áudio do PulseAudio no DSLinux 4 @ N.A"
read -r -p "[*] Deseja fazer as alterações? [S/n]  " response
if [[ "$response" =~ ^([sS][eE][yY]|[sS])$ ]]
then
	if (( $EUID != 0 )); then # Verifica se o script está sendo executado como root
    	echo -e "${Red}[!] Você precisa estar no usuário root para executar esse script!${ColorOff}"
    	exit
	fi

	echo
	echo -e "${Cyan}[*] Procurando módulos de áudio...${ColorOff}"
	sleep 1; echo
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

	if [ "$(echo $OUT_GS | sed -re '/^$/d' | wc -l)" -eq 1 ] ; then # Verifica se algum módulo foi encontrado, caso contrário, o script é abortado
		echo; sleep 1
		echo -e "${Cyan}[*] Apagando configurações antigas...${ColorOff}"
		sleep 1
		DELETE_OLD_CONFIG
		echo -e "${Cyan}[*] Adicionando configurações novas...${ColorOff}"
		sleep 1
		ADD_NEW_CONFIG
		if [[ $? -eq 0 ]]; then # Verifica se as configurações novas foram adicionas corretamente
			echo
			echo -e "${Green}[+] Configurações finalizadas com sucesso.${ColorOff}"
			echo
			echo -e "${Cyan}[*] Resumo: ${ColorOff}"
			tail -n 4 /etc/pulse/default.pa
		fi
	else
		echo
		DELETE_OLD_CONFIG
		echo -e "${Red}[!] As configurações não puderam ser finalizadas.${ColorOff}"
	fi
else
	echo -e "${Red}[!] Cancelando...${ColorOff}"
fi
