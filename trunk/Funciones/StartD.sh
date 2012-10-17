#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	4			#
#	Nombre:	startD.sh		#
#					#
#########################################



COMANDO="StartD"

chequeaProceso(){

  #El Parametro 1 es el proceso que voy a buscar
  PROC=$1
  PROC_LLAMADOR=$2

  #Busco en los procesos en ejecucion y omito "grep" ya que sino siempre se va a encontrar a si mismo
  # -w es para que busque coincidencia exacta en la palabra porque sino estamos obteniendo cualquier cosa.
  PID=`ps ax | grep -v $$ | grep -v grep | grep -v -w "$PROC_LLAMADOR" | grep $PROC`
  PID=`echo $PID | cut -f 1 -d ' '`
  echo $PID
  
}

chequeaVariables(){

  if ( [ "$BINDIR" != "" ]  && [ "$GRUPO" != "" ] && [ "$ARRIDIR" != "" ] && [ "$RECHDIR" != "" ] && [ "$MAEDIR" != "" ] ) then
    echo 0
  else
    echo 1
  fi

}

chequeaArchivosMaestros(){

  SERVICIOS=$MAEDIR/sistemas
  PATRONES=$MAEDIR/patrones

  #Chequeo que los archivos existan  
  if [ ! -f $SERVICIOS ] ; then      
      echo 1
      return
  fi
  
  if [ ! -f $PATRONES ] ; then
    echo 1
    return
  fi
  
  #Chequeo que los archivos tengan permisos de lectura
  if [ ! -r "$SERVICIOS" ] ; then
    echo 1
    return
  fi
  
  if [ ! -r "$PATRONES" ] ; then
    echo 1
    return
  fi
  
  
  echo 0
  return
}


chequeaDirectorios(){

  # Chequeo que existan los directorios
  if ([ ! -d "$GRUPO" ] && [ ! -d "$LOGDIR" ] && [ ! -d "$MAEDIR" ] && [ ! -d "$ARRIDIR" ] && [ ! -d "$RECHDIR" ]) then
    echo 1
    return
  fi
  echo 0
  return
}

  # Si alguna variable no esta definida error en la instalación
  if [ `chequeaVariables` -eq 1 ] ; then
    echo 1
  fi

  #CHEQUEAR INSTALACION

  if [ `chequeaDirectorios` -eq 1 ] ; then
    echo loguearW5.sh "$COMANDO" "SE" "Directorios necesarios no creados en la instalacion o no disponibles" 
    echo "Error: Directorios necesarios no creados en la instalacion o no disponibles"
    exit 1
  fi

  echo $MAEDIR
  
  if [ `chequeaArchivosMaestros` -eq 1 ] ; then
    echo loguearW5.sh "$COMANDO" "SE" "Archivos maestros no accesibles/disponibles"
    echo "Error: Archivos maestros no accesibles/disponibles"
    exit 1
  fi

#Detecto si detectaw5 esta corriendo
  DETECTAR_PID=`chequeaProceso DetectaW5.sh $$`
  if [ -z "$DETECTAR_PID" ]; then     
    bash DetectaW5.sh &
    echo loguearW5.sh "$COMANDO" "I" "Demonio DetectaW5 corriendo bajo el numero de proceso: <`chequeaProceso DetectaW5.sh $$`>" 
  else
    echo loguearW5.sh "$COMANDO" "E" "Demonio DetectaW5 ya ejecutado bajo PID: <`chequeaProceso DetectaW5.sh $$`>" 
    echo "Error: Demonio DetectaW5 ya ejecutado bajo PID: <`chequeaProceso DetectaW5.sh $$`>"
    exit 1
  fi
