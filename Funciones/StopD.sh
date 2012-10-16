#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	4			#
#	Nombre:	StopD.sh		#
#					#
#########################################



COMANDO="StopD"

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

DETECTAR_PID=`chequeaProceso DetectaW5.sh $$`
if ([ $DETECTAR_PID ]) then
    kill -9 $DETECTAR_PID
    echo LoguearW5.sh "$COMANDO" "I" "Se detuvo el demonio de DetectaW5 con PID: <$DETECTAR_PID>" 
else
   echo LoguearW5.sh "$COMANDO" "I" "No se pudo detener el demonio DetectaW5 pues no fue encontrado"
fi


