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

chequearVariables(){



  if ( [ "$BINDIR" != "" ]  && [ "$GRUPO" != "" ] && [ "$ARRIDIR" != "" ] && [ "$RECHDIR" != "" ] && [ "$MAEDIR" != "" ] && [ "$PROCDIR" != "" ] &&        	
       [ "$CONFDIR" != "" ] && [ "$ACEPDIR" != "" ] && [ "$LOGDIR" != "" ]) then
    echo 0
  else
    echo 1
  fi

}

chequearMaestros(){

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
  
  echo 0
  return
}


chequearDirectorios(){

  # Chequeo que existan los directorios
  if ( [ ! -d "$BINDIR" ]  && [ ! -d "$GRUPO" ] && [ ! -d "$ARRIDIR" ] && [ ! -d "$RECHDIR" ] && [ ! -d "$MAEDIR" ] && [ ! -d "$PROCDIR" ] && 
       [ ! -d "$CONFDIR" ] && [ ! -d "$ACEPDIR" ] && [ ! -d "$LOGDIR" ] ) then
    echo 1
  else
    echo 0
  fi
}

  # Si alguna variable no esta definida error en la instalación
  if [ `chequearVariables` -eq 1 ] ; then
    bash LoguearW5.sh "$COMANDO" -E 18
    exit 1
  fi

  #CHEQUEAR INSTALACION

  if [ `chequearDirectorios` -eq 1 ] ; then
    bash LoguearW5.sh "$COMANDO" -SE 17
    exit 1
  fi

 
  if [ `chequearMaestros` -eq 1 ] ; then
    bash LoguearW5.sh "$COMANDO" -SE 16
    exit 1
  fi

#Detecto si detectaw5 esta corriendo
  DETECTAR_PID=`chequeaProceso DetectaW5.sh $$`
  if [ -z "$DETECTAR_PID" ]; then     
    bash DetectaW5.sh &
  else
    bash LoguearW5.sh "$COMANDO" -I "Demonio DetectarW5 ya ejecutado (PID: <`chequeaProceso DetectaW5.sh $$`>)" 
    exit 1
  fi
