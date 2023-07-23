#!/bin/bash

#Colours
greenColour="\e[0;32m\033[0.1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[0.1m"
blueColour="\e[0;34m\033[0.1m"
yellowColour="\e[0;33m\033[0.1m"
purpleColour="\e[0;35m\033[0.1m"
turquoiseColour="\e[0;36m\033[0.1m"
grayColour="\e[0;37m\033[0.1m"

function ctrl_c(){
echo -e "\n\n${redColour}[!] Saliendo...${endcolour}\n"
tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){

echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Uso:${endcolour}\n"

echo -e "\t${purpleColour}u)${endcolour}${grayColour} Descargar o actualizar archivos necesarios${endcolour}"
echo -e "\t${purpleColour}m)${endcolour}${grayColour} Buscar por un nombre de maquina${endcolour}"
echo -e "\t${purpleColour}i)${endcolour}${grayColour} Buscar por direcion IP${endcolour}"
echo -e "\t${purpleColour}o)${endcolour}${grayColour} Buscar por el sistema operativo${endcolour}"
echo -e "\t${purpleColour}d)${endcolour}${grayColour} Buscar por la dificultad de una maquina${endcolour}"
echo -e "\t${purpleColour}s)${endcolour}${grayColour} Buscar por Skill ${endcolour}"
echo -e "\t${purpleColour}y)${endcolour}${grayColour} Obtener link de la resolucion de la maquina en Youtube${endcolour}"
echo -e "\t${purpleColour}h)${endcolour}${grayColour} Mostrar este panel de ayuda${endcolour}\n"
}

function updateFiles(){

  if [ ! -f bundle.js  ]; then
     tput civis
     echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Descargando archivos necesarios...${endcolour}"
     curl -s $main_url > bundle.js
     js-beautify bundle.js | sponge bundle.js
     echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Todos los archivos han sido descargados${endcolour}"
     tput cnorm
    else
     tput civis
     echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Comprobando si hay actualizaciones pendientes...${endcolour}"
     curl -s $main_url > bundle_temp.js
     js-beautify  bundle_temp.js | sponge bundle_temp.js
     md5_temp_value=$( md5sum bundle_temp.js | awk '{print $1}')
     md5_original_value=$( md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endcolour}${grayColour} No se han detectado actualizaciones, todo está actualizado ;)${endcolour}"
      rm bundle_temp.js
    else 
      echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Se han encontrado actualizaciones disponibles${endcolour}"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Los archivos han sido actualizados${endcolour}"
    fi

    tput cnorm
  fi
}

function searchMachine(){
 machineName="$1"

 machineName_checker="$(cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | grep -vE  "id:|sku:|resuelta:"| tr -d '"' | tr -d ',' | sed 's/^ *//')"

 if [  "$machineName_checker"  ]; then

  sleep 0.5

  echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Listando las propiedades de la maquina${endcolour}${blueColour} $machineName${endcolour}${grayColour}:${endcolour}\n"

  sleep 0.5

cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | grep -vE  "id:|sku:|resuelta:"| tr -d '"' | tr -d ',' | sed 's/^ *//'
else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe ${endcolour}\n"
 fi
}


function searchIP(){
  ipAddress="$1"

  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

if [ "$machineName"  ]; then

  sleep 0.5

  echo -e "\n${yellowColour}[+]${endcolour}${grayColour} La maquina correspondiente para la IP${endcolour}${yellowColour} $ipAddress${endcolour}${grayColour} es${endcolour}${blueColour} $machineName${endcolour}\n"
  else
    echo -e "\n${redColour}[!] La direccion IP proporcionada no existe ${endcolour}\n"
  fi

  sleep 0.5

  searchMachine $machineName

}

function getYoutubeLink(){

  machineName="$1"

  youtubeLink="$(cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | grep -vE  "id:|sku:|resuelta:"| tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

  if [ $youtubeLink  ]; then

    sleep 0.5

    echo -e "\n${yellowColour}[+]${endcolour}${grayColour} El tutorial para esta maquina esta en el siguiente link:${endcolour}${turquoiseColour} $youtubeLink${endcolour}\n"
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe ${endcolour}\n"
  fi

}

function getMachinesDifficulty(){
difficulty="$1"

results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5  | grep "name:" | awk 'NF{print $NF}'| tr -d '"' | tr -d ',' | column )"

  if [ "$results_check"  ]; then

    sleep 0.5

    echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Representando las maquinas que posee un nivel de dificultad${endcolour}${redColour} $difficulty${endcolour}${grayColour}:${endcolour}\n"

    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5  | grep "name:" | awk 'NF{print $NF}'| tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe ${endcolour}\n"
  fi
}

function getOSMachines(){
os="$1"

os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$os_results"  ]; then

  sleep 0.5

  echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Mostrando las maquinas cuyo sistema operativo es ${endcolour}${greenColour}$os${endcolour}${grayColour}:${endcolour}\n"

  cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe ${endcolour}\n"
  fi
}

function getOSDifficultyMachines(){
difficulty="$1"
os="$2"

check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_results"  ]; then

    sleep 0.5

    echo -e "\n${yellowColour}[+]${endcolour}${grayColour} Listando maquinas de dificultad${endcolour}${redColour} $difficulty${endcolour}${grayColour} que tengan sistema operativo${endcolour}${greenColour} $os${endcolour}${grayColour}:${endcolour}\n"

  cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
  echo -e "\n${redColour}[!] Se ha indicado una dificultad y/o sistema operativo incorrectos${endcolour}\n"
  fi
}

function getSkill(){
  skill="$1"

  check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$check_skill" ]; then

    sleep 0.5

    echo -e "\n${yellowColour}[+]${endcolour}${grayColour} A continuacion se representan las maquinas donde se trabaja la skill${endcolour}${blueColour} $skill${endcolour}${yellowColour}:${endcolour}\n"
  cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
  echo -e "\n${redColour}[!] No se ha encontrado ninguna maquina con la skill indicada${endcolour}\n"
  fi

}

# Indicadores
declare -i parameter_counter=0

# chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG";  chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG";  chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2  ]; then
  updateFiles
elif [ $parameter_counter -eq 3  ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4  ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5  ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6  ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7  ]; then
  getSkill "$skill"
elif [ $chivato_difficulty -eq 1  ] && [ $chivato_os -eq 1  ]; then
  getOSDifficultyMachines $difficulty $os
else
 helpPanel
fi
