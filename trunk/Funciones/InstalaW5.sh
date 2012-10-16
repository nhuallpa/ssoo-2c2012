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
# 2 - 

USER=`whoami`		#devuelve usuario actual del sistema
#COMMAND=`ps -p $PPID -o comm=`	#obtengo nombre del comando que lo invoco
COMMAND="InstalaW5.sh"
GRUPO="./"

CONFDIR="$GRUPO/confdir"
INSTALAW5_SETUPFILE="$CONFDIR/InstalaW5.conf"
INSTALAW5_TEMPFILE="$CONFDIR/InstalaW5.temp"
INSTALAW5_LOGFILE="$CONFDIR/InstalaW5.log"		#archivo de log

INSTALAW5_STATE_COMPLETE="DONE"
INSTALAW5_STATE_INCOMPLETE="PARTIAL"
INSTALAW5_STATE_FRESHINSTALL="FRESH"

# Variables para instalacion y reanudación
INSTALAW5_MAEFILES=("patrones")
INSTALAW5_BINFILES=(BuscarW5.sh IniciarW5.sh ListarW5.sh LoguearW5.sh MirarW5.sh MoverW5.sh)


#---------- Funciones de bajo nivel ----------

## Funcion de log - CONSOLIDAR CON LoguearW5+
function logErrorFatal {
	DATE=`date '+$x $X'`
	echo "$DATA-$USER-$COMMAND-ES-$1" >> "$INSTALAW5_LOGFILE"
	echo $1
}

function logErrorOnly  {
	DATE=`date '+%x %X '` 		#devuelve la fecha del sistema dd/MM/yy hh:mm:ss
	echo "$DATE-$USER-$COMMAND-E-$1" >> "$INSTALAW5_LOGFILE"
}

function logOnly  {
	DATE=`date '+%x %X '` 		#devuelve la fecha del sistema dd/MM/yy hh:mm:ss
	echo "$DATE-$USER-$COMMAND-I-$1" >> "$INSTALAW5_LOGFILE"
}

function logError {
	logErrorOnly "$1"
	echo "$1"
}

function log {
	logOnly "$1"
	echo "$1"
}

function logInstallStep {
	logOnly "Se ha completado el paso $1 de la instalación"
}

## Funcion que verifica si existe y directorio, y sino, lo crea
function createDirIfNotExist {
	mkdir -p "$1"
}

## Muestra el mensaje de bienvenida
function hello {
	log "Comando InstalaW5 Inicio de Ejecución"
	log "TP SO7508 Segundo Cuatrimestre 2012. Tema W Copyright © Grupo 04"
}

## Obtiene los componentes que se han instalado
function getInstalledComponentsFromFile {
	log "getInstalledComponents"
}

## Espera a que el usuario ingrese S o N. Guarda el resultado en una variable llamada replyYesOrNo
function waitForYesOrNo {
	log "waitForYesOrNo"
}

## devuelve la cantidad de espacio libre en el path actual
function getFreeUserSpaceInMegabytes {
	freespace=`df -Phm . | tail -1 | awk '{print $4}'`
	echo "$freespace"
}


function isValidPositiveNumber {
	validation=`echo $1 | grep "^[0-9][0-9]*$"`
	if  [ "$validation" != "" ]; then
		if [ $1 -ge 1 ] ; then
     			echo "0"
   		else
     			echo "1"
   		fi
	else
  		echo "1"
	fi
}

## Numero $1 menor o igual que $2
function isPositiveNumberLessOrEqualThan {
	validPositiveNumber=`isValidPositiveNumber $1`
	if [ "$validPositiveNumber" == "0" ]; then	
		if [ $1 -le $2 ]; then
			echo "0"	
		else
			echo "1"	
		fi
	else
		echo "2"
	fi
}


function isValidString {
	logOnly "Verificando si el string '$1' es valido"

	validation=`echo "$1" | grep "^\(/\([A-Za-z0-9-]\+\)\)\+$"`

	if  [ "$validation" != "" ] ;then
   		echo "0"
	else
   		echo "1"
	fi
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
			logError "Para instalar W-FIVE es necesario contar con Perl $required_version o superior instalado. Efectúe su instalación e inténtelo nuevamente.";
			logError "Proceso de Instalación Cancelado.";
		fi
		exit 1;
	else
		errorMsg="Perl Version: $perl_version";
		log "$errorMsg";
	fi
}



## Funcion que obtiene el estado de la ultima instalacion
function getLastInstallationState {
	# Verificamos si existe el archivo de configuracion. $INSTALAW5_SETUPFILE
	# 	Si existe, obtenemos la cantidad de componentes que quedan por instalar.
	# 		Si la cantidad de componentes que quedan por installar es mayor a cero, entonces la instalacion esta incompleta.
	#		Si la cantidad de componentes que quedan por instalar es igual a cero, la instalación finalizo correctamente
	#	Si no existe el archivo, verificamos si existe el archivo de instalacion temporal $INSTALAW5_TEMPFILE
	#		Si existe y la cantidad de componentes instalados es mayor a cero, la instalacion esta incompleta
	#		Si existe y la cantidad de componentes instalados es igual a cero, la instalacion aun no empezo
	
	if [ -e "$INSTALAW5_SETUPFILE" ];
	then
		
		getInstalledComponentsFromFile "$INSTALAW5_SETUPFILE"
		
		if [ "$notInstCount" -eq "0" ];
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


## STEP 4 - Muestra la informacion de la instalacion
function showInstallInformation {
	
	GRUPOFullPath=$(readlink -f "$GRUPO")
	CONFDIRFullPath=$(readlink -f "$CONFDIR")

	log "Directorio de Trabajo para la instalacion: $GRUPOFullPath"
	GRUPOContent=`ls -c $GRUPO`
	log "Contenido del directorio de trabajo: $GRUPOContent"

	log "Librería del Sistema: $CONFDIRFullPath"
	CONFDIRContent=`ls -c $CONFDIR`
	log "Contenido del directorio: $CONFDIRContent"	


	log "Estado de la instalacion: PENDIENTE

	Para completar la instalación Ud. Deberá:
	
	1) Definir el directorio de instalación de los ejecutables
	2) Definir el directorio de instalación de los archivos maestros
	3) Definir el directorio de arribo de archivos externos
	4) Definir el espacio mínimo libre para el arribo de archivos externos
	5) Definir el directorio de grabación de los archivos externos rechazados
	6) Definir el directorio de grabación de los logs de auditoria
	7) Definir la extensión y tamaño máximo para los archivos de log
	8) Definir el directorio de grabación de los reportes de salida"
}

## STEP 5 - definir directorio de instalacion de ejecutables
function defineBINDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de instalación de los ejecutables ($BINDIR):"; read userbindir
		
		if [ "$userbindir" != "" ]; then
			validInput=`isValidString $userbindir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userbindir' como directorio de trabajo para 'bin'"
				BINDIR=$userbindir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $BINDIR como directorio para ejecutables"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 0
}

## STEP 6 - definir directorio de instalacion de archivos maestros
function defineMAEDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de instalación de los archivos maestros ($MAEDIR):"; read usermaedir
		
		if [ "$usermaedir" != "" ]; then
			validInput=`isValidString $userbindir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$usermaedir' como directorio de trabajo para datos maestros"
				MAEDIR=$usermaedir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $MAEDIR como directorio para los datos maestros"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 1
}

## STEP 7 - definir directorio de arribo de archivos externos
function defineARRIDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de arribo de archivos externos ($ARRIDIR):"; read userarridir
		
		if [ "$userarridir" != "" ]; then
			validInput=`isValidString $userarridir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userarridir' como directorio de trabajo para el arribo de archivos externos"
				ARRIDIR=$userarridir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $ARRIDIR como directorio para el arribo de archivos externos"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 2
}

#STEP 8 Definir espacio libre
function defineARRIDirSpace {
	# Espera por que el usuario ingrese un tamaño de espacio libre valido (mayor a 1MB)

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el espacio mínimo libre (al menos 1MB) para el arribo de archivos externos en MBytes ($DATASIZE):"; read userdatasize
		
		if [ "$userdatasize" != "" ]; then
			userfreespace=`getFreeUserSpaceInMegabytes`
			validInput=`isPositiveNumberLessOrEqualThan $userdatasize $userfreespace`
			if [ "$validInput" = "0" ]; then
				logOnly "El usuario ingreso $userdatasize MBytes como espacio minimo libre"
				DATASIZE=$userfreespace;
				validInput="1"
    			else 
				if [ "$validInput" = "1" ]; then
	      				echo $validInput
					logErrorOnly "El usuario esta intentando reservar $userdatasize MBytes."
					logError "Insuficiente espacio en disco."
					logError "Espacio disponible: $userfreespace Mb."
					logError "Espacio requerido $userdatasize Mb"
					logError "Cancele la instalación e inténtelo mas tarde o vuelva a intentarlo con otro valor."
				elif [ "$validInput" = "2" ]; then
					logErrorOnly "El usuario esta intentando reservar $userdatasize MBytes."
					logError "El tamaño de espacio a reserver debe ser mayor a 1MBytes"
				fi
				validInput="0"
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $DATASIZE como espacio minimo libre para archivos externos"
  		fi
	done
	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 3
}

## STEP 10 - definir directorio de arribo de archivos externos rechazados
function defineRECHDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de grabacion de los archivos externos rechazados ($RECHDIR):"; read userrechdir
		
		if [ "$userrechdir" != "" ]; then
			validInput=`isValidString $userrechdir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userrechdir' como directorio de trabajo para la grabación de los archivos externos aceptados"
				RECHDIR=$userrechdir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $RECHDIR como directorio para la grabación de archivos externos aceptados"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 4
}

## STEP 11 - definir directorio de arribo de archivos aceptados
function defineACEPDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de grabación de los archivis externos aceptados ($ACEPDIR):"; read useracepdir
		
		if [ "$useracepdir" != "" ]; then
			validInput=`isValidString $useracepdir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$useracepdir' como directorio de trabajo para la grabación de los archivos externos aceptados"
				ACEPDIR=$useracepdir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $RECHDIR como directorio para la grabación de archivos externos aceptados"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 5
}
			
#STEP 12 Definir PROCDIR
function definePROCDir	{
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de grabación de los archivos procesados ($PROCDIR):"; read userprocdir
		
		if [ "$userprocdir" != "" ]; then
			validInput=`isValidString $userprocdir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userprocdir' como directorio de trabajo para archivos procesados"
				PROCDIR=$userprocdir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $PROCDIR como directorio para los archivos procesados"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 6
}

#STEP 13a Definir LOGDIR
function defineLOGDir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de grabación de los archivos de log ($LOGDIR):"; read userlogdir
		
		if [ "$userlogdir" != "" ]; then
			validInput=`isValidString $userlogdir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userlogdir' como directorio de trabajo para la grabación de los archivos de log"
				LOGDIR=$userlogdir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $LOGDIR como directorio para la grabación de archivos de log"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 7
}
			
#STEP 13b Definir LOGEXT
function defineLOGExt {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina la extension de los archivos de log ($LOGEXT):"; read userlogext
		
		if [ "$userlogext" != "" ]; then
			validInput=`isValidString $userlogext`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userlogext' como extensión de los archivos de log"
				#si la extensión no comienza con '.' entonces se lo agregamos
				hasDot=`echo "log" | grep -c '^\.'`
				if [ hasDot = 0]; then
					userlogext="$userlogext."
				fi
				LOGEXT=$userlogext;
    			else
	      			echo $validInput
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $LOGEXT como extension de los archivos de log"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 8
}

#STEP 14  Definir tamaño maximo de archivo de log
function defineLOGSize {
	# Espera por que el usuario ingrese un tamaño de archivo de log valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el tamaño máximo para los archivos $LOGEXT en Kbytes ($LOGSIZE):"; read userlogsize
		
		if [ "$userlogsize" != "" ]; then
			validInput=`isPositiveNumber $userlogsize`
			if [ "$validInput" = "0" ]; then
				logOnly "El usuario ingreso $userlogsize KBytes como tamaño maximo de archivo de log"
				LOGSIZE=$userlogsize;
				validInput="1"
    			else 
				logError "Debe ingresar un tamaño mayor a 1KByte."
				validInput="0"
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $LOGSIZE como tamaño maximo del archivo de log"
  		fi
	done
	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 9

}

#STEP 15 Definir REPODIR
function defineREPODir {
	# Espera por que el usuario ingrese un directorio valido

	validInput="0"
	while [ "$validInput" != "1" ] ; do

		log "Defina el directorio de grabación de los reportes de salida ($REPODIR):"; read userrepodir
		
		if [ "$userrepodir" != "" ]; then
			va

lidInput=`isValidString $userrepodir`
			if [ "$validInput" = "1" ]; then
				logOnly "El usuario ingreso '$userrepodir' como directorio de trabajo para la grabación de los reportes de salida"
				REPODIR=$userrepodir;
    			else
	      			echo $validInput
				logError "El directorio ingresado no es valido"	
	   		fi
  		else
    			validInput="1"
			logOnly "El usuario quiere mantener $REPODIR como directorio para la grabación de los reportes de salida"
  		fi
	done

	#registrar este paso en el archivo de instalacion temporal para poder reanudar el proceso
	logInstallStep 10
}

## STEP 16 Mostrar parametros de instalacion
function showInstallParams {
	log "Libreria del Sistema: $CONFDIR"
	log "Ejecutables: $BINDIR"
	log "Archivos maestros: $MAEDIR"
	log "Directorio de arribo de archivos externos: $ARRIDIR"
	log "Espacio minimo libre para arribos: $DATSIZE MBytes"
	log "Archivos externos aceptados $ACEPDIR"  
	log "Archivos externos rechazados $RECHDIR"
	log "Archivos procesados: $PROCDIR"
	log "Reportes de salida: $REPODIR"
	log "Logs de auditoria del sistema: $LOGDIR/<comando>$LOGEXT"
	log "Tamaño máximo para los archivos de log del sistema: $LOGSIZE KBytes"
	log "Estado de la instalación: $1"
	
	#esperar input, si es SI, salimos con codigo 0 y empezamos la instalacion
	#si es NO, salimos con codigo 1 y volvemos al paso defineARRIDir
	selectedOption=0
      	while [ "$selectedOption" != "s" -a "$selectedOption" != "S" -a "$selectedOption" != "n" -a "$selectedOption" != "N" ] ; do
		log "Los datos ingresados son correctos? (Si-No)"; read -n1 selectedOption
		if [ "$selectedOption" = "s" -o "$selectedOption" = "S" ] ; then
        		confirmData="0"            			        
        	elif [ "$selectedOption" = "n" -o "$selectedOption" = "N" ] ; then
        		confirmData="1"	
		fi
	done

	logInstallStep 11
}

##STEP 18 crear directorios
function createW5Directories {
	log "Creando estructura de directorios..."
	createDirIfNotExist "$BINDIR"
	createDirIfNotExist "$MAEDIR"
	createDirIfNotExist "$ARRIDIR"
	createDirIfNotExist "$RECHDIR"
	createDirIfNotExist "$ACEPDIR"
	createDirIfNotExist "$PROCDIR"
	createDirIfNotExist "$LOGDIR"
	createDirIfNotExist "$REPODIR"
}

##STEP 18.2 copiar archivos maestro a MAEDIR
function installMAEFiles {
	log "Instalando Archivos Maestros"
	
	## for file in INSTALW5_MAEFILES -> copy into $MAEDIR
	for file in ${INSTALAW5_MAEFILES[*]}
    	do
		# Si existe el archivo lo copio en MAEDIR
        	if  [ -e "$file" ];     then
			cp $file $MAEDIR
			# seteo los permisos correspondientes
	        	chmod 444  $MAEDIR/$file
        	else
			# ERROR FATAL - Un archivo no se ha podido copiar porque no existe en el directorio de instalacion
			logErrorFatal "El archivo $file no se ha encontrado en el directorio de instalación y no se ha podido copiar en el directorio de destino $MAEDIR"
        	fi
    	done
}

##STEP 18.2 copiar programas y funciones a BINDIR
function installBINFiles {
	log "Instalando Programas y Funciones"
	
	## for element in INSTALAW5_BINDIR -> copy into $BIRDIR
	for file in ${INSTALAW5_BINFILES[*]}
    	do
		# Si existe el archivo lo copio en BINDIR
        	if  [ -e "$file" ];     then
			cp $file $BINDIR
			# seteo los permisos correspondientes
	        	chmod +x  $BINDIR/$file
        	else
			# ERROR FATAL - Un archivo no se ha podido copiar porque no existe en el directorio de instalacion
			logErrorFatal "El archivo $file no se ha encontrado en el directorio de instalación y no se ha podido copiar en el directorio de destino $MAEDIR"
        	fi
    	done
}

##STEP 18.3 actualizar la configuracion del sistma
function updateConfigFile {
	log "Actualizando la configuración del sistema"

	## Si el archivo existe, guardo toda configuracion posterior 
	if  test -s "$INSTALAW5_SETUPFILE" ;then
		#ya existe el archivo configuracion, debo cambiar las variables que cambiaron
	  echo ""
	  ultimaslineas=`tail -n +12 $INSTALAW5_SETUPFILE`
	  echo $ultimaslineas
	 # echo "CONFIGURACION"|> $INSTALAW5_SETUPFILE
	fi

	currentDate=`date +"%D %X"`

	echo "GRUPO=$GRUPO=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "CONFDIR=$CONFDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "ARRIDIR=$ARRIDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "ACEPDIR=$ACEPDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "RECHDIR=$RECHDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "BINDIR=$BINDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "MAEDIR=$MAEDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "REPODIR=$REPODIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "PROCDIR=$PROCDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "LOGDIR=$LOGDIR=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "LOGEXT=$LOGEXT=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "LOGSIZE=$LOGSIZE=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "DATASIZE=$DATASIZE=$USER=$currentDate" >> $INSTALAW5_SETUPFILE

	echo "SECUENCIA1=0=$USER=$currentDate" >> $INSTALAW5_SETUPFILE
	echo "SECUENCIA2=0=$USER=$currentDate" >> $INSTALAW5_SETUPFILE


  	if  [ -n "$ultimaslineas" ] ; then
    		echo $ultimaslineas >> $CONFIGURACION
  	fi
}

## Verifica que esten todos los ejecutables
function lookForBINFiles {
	missingBinaries=""
	binaryFiles=`ls $BINDIR`

	for file in ${INSTALAW5_BINFILES[*]}
	do
		present=`echo $binaryFiles | grep $file`

		if [ -z "$present" ]; then
			missingBinaries="$missingBinaries $file"
		fi
	done
	echo $missingBinaries
}

## Verifica que esten todos los archivos maestros
function lookForMAEFiles {
	missingMasters=""
	masterFiles=`ls $BINDIR`

	for file in ${INSTALAW5_MAEFILES[*]}
	do
		present=`echo $masterFiles | grep $file`

		if [ -z "$present" ]; then
			missingMasters="$missingMasters $file"
		fi
	done
	echo $missingMasters
}

## Instalacion incompleta
###	declare missingMAE=""
###	declare missingBIN=""
###	declare missings=""
###	declare notMissingsCount=0
function getMissingsFiles {

	# Compruebo directorios faltantes
	reqDirs=($ARRIDIR $RECHDIR $BINDIR $ACEPDIR $MAEDIR $REPODIR $LOGDIR $PROCDIR)
	
	for directory in ${reqDirs[*]}
	do
	    if  [ -d "$directory" ] ;then
        	notMissingsCount=$(($notMissingsCount +1))
	        if [ "$directory" = "$BINDIR" ] ; then
	        	missingBIN=`lookForBINFiles`
        	elif  [ "$directory" = "$MAEDIR" ] ; then
          		missingMAE=`lookForMAEFiles`
	    	else
	      		missings=$missings" "$directory
	    	fi
	done

	
}


## Funcion que obtiene los valores por defecto de un archivo 
function getValuesFromFile {
	logOnly "Leyendo valor por defecto del archivo $1"
}


## Setea los valores por defecto para las variables
function setDefaultValues {
	BINDIR="$GRUPO/bin"
	MAEDIR="$GRUPO/mae"
	ARRIDIR="$GRUPO/arribos"
	DATASIZE="100"
	RECHDIR="$GRUPO/rechazados"
	ACEPDIR="$GRUPO/aceptados"
	PROCDIR="$GRUPO/procesados"
	LOGDIR="$GRUPO/log"
	LOGEXT=".log"
	LOGSIZE="400"
	REPODIR="$GRUPO/reportes"
}


## Funcion principal
function startInstallWFIVE {	
	# Chequea si es la unica instancia de la instalacion

	# Crea el directirio donde estaran los archivos de instalacion (configuracion y temporal), si este no existe
	createDirIfNotExist $CONFDIR

	# Inicia la instalacion
	hello

	# Verificar si es una sola instancia	

	# obtiene el estado de la ultima instalacion
	
	declare lastInstallationState
	declare installedComponents

	getLastInstallationState

	case "$lastInstallationState" in

		"$INSTALAW5_STATE_FRESHINSTALL")
			#PRE 
			setDefaultValues

			#STEP 3 Chequear que PERL este instalado
			isPerlIstalled  #Si no esta instalado, esta funcion sale con error 1
			
			#STEP 4 Brinda la informacion de la instalacion
			showInstallInformation
			
			#STEP 5 Definir BINDIR
			defineBINDir

			#STEP 6 Definir MAEDIR
			defineMAEDir

			confirmedInstallParams="0"
			while [ "$confirmedInstallParams" != "1" ] ; do

				#STEP 7 Definir ARRIDIR
				defineARRIDir

				#STEP 8 Definir espacio libre
				defineARRIDirSpace
	
				#STEP 10 Definir RECHDIR
				defineRECHDir

				#STEP 11 Definir ACEPDIR
				defineACEPDir	

				#STEP 12 Definir PROCDIR
				definePROCDir	

				#STEP 13a Definir LOGDIR
				defineLOGDir	
				#STEP 13b Definir LOGEXT
				defineLOGExt
	
				#STEP 14  Definir tamaño maximo de archivo de log
				defineLOGSize

				#STEP 15 Definir REPODIR
				defineREPODir

				`clear`
				hello
	
				declare confirmData
				#STEP 16 Mostrar parametros de instalacion
				showInstallParams "LISTA"

				if [ "$confirmData" = "0" ]; then
					# iniciar instalacion

					#STEP 18				
					createW5Directories
					installMAEFiles
					installBINFiles

					updateConfigFile
					confirmedInstallParams="1"
					echo "Instalación concluida"
				else
					confirmedInstallParams="0"
					echo "Instalación cancelada"
				fi
			done
			
		;;


		"$INSTALAW5_STATE_INCOMPLETE")
	
			declare missingMAE=""
			declare missingBIN=""
			declare missings=""
			declare notMissingsCount=0

			getMissingsFiles

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
				echo "A"
			else 
				echo "B"
			fi
		;;


		"$INSTALAW5_STATE_COMPLETE")
			showInstallParams "COMPLETA"
		;;

	esac

}

#---------- Inicia el proceso de instalacion ----------

## Iniciar Instalacion
startInstallWFIVE

## por default suponemos que la instalacion termina correctamente

