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


###################
# FUNÇÕES GLOBAIS #
###################
HELP() { # Exibe informações de utilização a respeito do script
    echo "PulseAudio Fixer - Versão 1.0"
    echo "Desenvolvimento por Nicolas Araujo (nicolas.araujo@deltasul.com.br)"
    echo
    echo "UTILIZAÇÃO"
    echo "  ./pulse-fixer.sh [opções]"
    echo
    echo "OPÇÕES PRINCIPAIS"
    echo "  --default           configura headsets utilizados nas lojas por padrão (Felitron & Multilaser)"
    echo "  --express           configuração padrão expressa, sem a confirmação inicial"
    echo
    echo "OPÇÕES COMPLEMENTARES"
    echo "  [...] --kill        mata o processo do PulseAudio, forçando o efeito de novas alterações"
}

GREP_SINK() { # Busca os speakers (fones de ouvido) disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sinks | grep -E 'Nome.*PxnP|Nome.*EPKO' | sed 's/[[:blank:]]//g' | cut -d ':' -f 2"
}

GREP_SOURCE() { # Busca os microfones disponíveis no PulseAudio
	su manager -s /bin/bash -c "pactl list sources | grep -E 'Nome.*PxnP.*mono|Nome.*EPKO.*mono' | sed 's/[[:blank:]]//g' | cut -d ':' -f 2"
}

DELETE_OLD_CONFIG() { # Deleta as configurações default antigas
	sed -i '/set-default-*/d' /etc/pulse/default.pa
}

ADD_NEW_CONFIG() { # Adiciona as novas configurações armazenadas nas variáveis OUT_GS e OUT_GM
	echo "set-default-sink "$OUT_GS >> /etc/pulse/default.pa
	echo "set-default-source "$OUT_GM >> /etc/pulse/default.pa
}

KILL_PULSEAUDIO() {
    sleep 1
    echo
    echo "[*] Interrompendo processos do PulseAudio..."
    killall pulseaudio
}


######################
# MENU DE ARGUMENTOS #
######################

if [[ "$1" == "--default" ]]; then
    # Shell interativo
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
                tail -n 2 /etc/pulse/default.pa
            fi

            if [[ "$2" == "--kill" ]]; then
                KILL_PULSEAUDIO
            fi
        else
            echo
            DELETE_OLD_CONFIG
            echo -e "${Red}[!] As configurações não puderam ser finalizadas.${ColorOff}"
        fi
    else
        echo -e "${Red}[!] Cancelando...${ColorOff}"
    fi



#####################################
# --EXPRESS - CONFIGURAÇÃO EXPRESSA #
#####################################

elif [[ "$1" == "--express" ]]; then
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
            tail -n 2 /etc/pulse/default.pa
        fi

        if [[ "$2" == "--kill" ]]; then
            KILL_PULSEAUDIO
        fi
    else
        echo
        DELETE_OLD_CONFIG
        echo -e "${Red}[!] As configurações não puderam ser finalizadas.${ColorOff}"
    fi

else
    HELP
fi
