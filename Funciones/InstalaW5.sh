#!/bin/bash
# 
# Ejemplo: 
# InstalaW5.sh
#
# DESCRIPCION: Instala el software W-FIVE
#
# Exit Codes
# 0 - Se ha instalado correctamente
# 1 - No se ha realizado la instalacion
# 2 - La instalacion no se ha completado

LOGFILE="InstalaW5.log"		#archivo de log
USER=`whoami`		#devuelve usuario actual del sistema
COMMAND=`ps -p $PPID -o comm=`	#obtengo nombre del comando que lo invoco

GROUP="../deploy"

INSTALAW5_SETUPDIR="$GRUPO/confdir"
INSTALAW5_sETUPFILE="$SETUPDIR/InstalaW5.temp"
INSTALAW5_TEMPFILE="$SETUPDIR/InstalaW5.conf"

INSTALAW5_STATE_COMPLETE="DONE"
INSTALAW5_STATE_INCOMPLETE="PARTIAL"
INSTALAW5_STATE_FRESHINSTALL="FRESH"


#---------- Funciones de bajo nivel ----------

## Funcion de log - CONSOLIDAR CON LoguearW5
function log {
	DATE=`date '+%x %X '` 		#devuelve la fecha del sistema dd/MM/yy hh:mm:ss
	echo "$DATE-$USER-$COMANDO-$1" >>$LOGFILE 		#Copio todo en el archivo 
	echo "$1"
}

## Funcion que verifica si existe y directorio, y sino, lo crea
function createDirIfNotExist {
	mkdir -p "$1"
}

## Muestra el mensaje de bienvenida
function hello {
	log "TP SO7508 Segundo Cuatrimestre 2012. Tema W Copyright © Grupo 04"
}

## Obtiene los componentes que se han instalado
function getInstalledComponentsFromFile {

}

## Espera a que el usuario ingrese S o N. Guarda el resultado en una variable llamada replyYesOrNo
function waitForYesOrNo {

}

#---------- Funciones de alto nivel ----------

## Comprueba que perl este instalado, y que la version sea igual o mayor a la requerida
function isPerlIstalled {
	log "Comprobando version de Perl..";
	declare required_version=5
	declare perl_version=`perl -v | sed -n 's/.*v\([0-9]*\)\.[0-9]*\.[0-9]*.*/\1/p'`
	declare errorMsg
	if [ "$perl_version" -lt "$required_version" ]
	then
		if [ -z "$perl_version" ]
		then
			errorMsg="Para instalar W-FIVE es necesario contar con Perl $required_version o superior instalado. Efectúe su instalación e inténtelo nuevamente. Proceso de Instalación Cancelado.";
			logMsg "$errorMsg";
		fi
		exit 1;
	else
		errorMsg="Version de Perl instalada: $perl_version";
		log "$errorMsg";
	fi
}



## Funcion que obtiene el estado de la ultima instalacion
function getLastInstallationState {
	# Verificamos si existe el archivo de configuracion. $INSTALAW5_sETUPFILE
	# 	Si existe, obtenemos la cantidad de componentes que quedan por instalar.
	# 		Si la cantidad de componentes que quedan por installar es mayor a cero, entonces la instalacion esta incompleta.
	#		Si la cantidad de componentes que quedan por instalar es igual a cero, la instalación finalizo correctamente
	#	Si no existe el archivo, verificamos si existe el archivo de instalacion temporal $INSTALAW5_TEMPFILE
	#		Si existe y la cantidad de componentes instalados es mayor a cero, la instalacion esta incompleta
	#		Si existe y la cantidad de componentes instalados es igual a cero, la instalacion aun no empezo
	
	if [ -e "$INSTALAW5_sETUPFILE" ];
	then
		
		getInstalledComponentsFromFile "$INSTALAW5_SETUPFILE"
		
		if [[ "$notInstCount" -eq "0" ]];
		then
			lastInstallationState=$INSTALAW5_STATE_COMPLETE
		else
			lastInstallationState=$INSTALAW5_STATE_INCOMPLETE
		fi
	else
		if [ -e "$INSTALAW5_TEMPFILE" ];
		then
			getInstalledComponentsFromFile "$INSTALAW5_TEMPFILE"
			
			if [[ "$instCount" -eq "0" ]];
			then
				lastInstallationState=$INSTALAW5_STATE_FRESHINSTALL
			else
				lastInstallationState=$INSTALAW5_STATE_INCOMPLETE
			fi
		else
			# restauramos los valores por default
			#for i in ${!vars_default[*]}
			#do
			#	vars_user["$i"]="${vars_default[$i]}"
			#done

			lastInstallationState=$INSTALAW5_STATE_FRESHINSTALL
		fi
	fi	

}

## Funcion principal
function startInstallWFIVE {
	# Inicia la instalacion
	hello

	# Crea el directirio donde estaran los archivos de instalacion (configuracion y temporal), si este no existe
	createDirIfNotExist $INSTALAW5_SETUPDIR

	# obtiene el estado de la ultima instalacion
	
	declare lastInstallationState
	declare installedComponents

	getLastInstallationState

	case "$lastInstallationState" in

		"$INSTALAW5_STATE_FRESHINSTALL")

		;;

		"$INSTALAW5_STATE_INCOMPLETE")
			# Log de archivos existentes

			# Mostrar estado de la instalacion
			log "Estado de la instalacion: INCOMPLETA"
			
			# Mostrar mensaje para continuar con la instalacion
			log "Desea completar la instalacion? (Si-No)"
			
			# Esperar la respuesta del usuario
			declare replyYesOrNo
			waitForYesOrNo

			if ( "$replyYesOrNo" == "YES")
				then
				
			else 

			fi
			
			

		;;


		"$INSTALAW5_STATE_COMPLETE")

		;;

	esac

}

#---------- Inicia el proceso de instalacion ----------

## Iniciar Instalacion
startInstallWFIVE

## por default suponemos que la instalacion termina correctamente
exit 0
