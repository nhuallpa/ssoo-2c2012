#!/bin/bash
#
# Comando (obligatorio)
# Filtros (opcionales y a definir por el desarrollador)
# Otros parámetros u opciones a especificar por el desarrollador
#
# Ejemplo: 
# ./MirarW5.sh <comando> <filtro> <[argumento]>
#
# DESCRIPCION: El servicio que brinda esta función es generar una visualización amigable del contenido 
# del archivo de log correspondiente al comando pasado como parámetro.
#


MODO_DE_USO="\n"\
"Modo de Uso:\n"\
"MirarW5.sh [comando] [opcion] [argumento]\n"\
"\n"\
"La opción deberá ser una de las siguientes:\n"\
"-h, --help :	Muestra la forma de uso del comando MirarW5.sh.\n"\
"-f, --file :	Muestra el contenido del archivo de log del comando pasado por parámetro. P.ej BuscarW5.sh -f\n"\
"-n, --ultN :	Muestra las ultimas n lineas del archivo. Por defecto se muestran todas las líneas del archivo. P.ej. BuscarW5.sh -n 10\n"\
"-b, --buscar:	Muestra las lineas del archivo que contienen la cadena especificada. P.ej. BuscarW5.sh -b cadenaABuscar\n"\
"\n"\

ultimasLineas=
cadenaABuscar=
archivo=

case $2 in
         -h|--help ) 
	    echo -e $MODO_DE_USO
	    exit 0 
	    ;;
         -n|--ultN )
             ultimasLineas=$3	#Guardo la cantidad de lineas que quiero mostrar
	     archivo=$1          #guardo nombre del archivo
	     ;;
         -b|--buscar )
             cadenaABuscar=$3	 #Me guardo la cadena a buscar dentro del archivo
	     archivo=$1          #guardo nombre del archivo
	    ;;
         -f|--file )
             archivo=$1           #guardo nombre del archivo
	     ;;
         *)
             echo -e $MODO_DE_USO
             exit;;
esac

#La extensión por default será “log”  (si no se definio en la configuracion o var de ambiente).
if [ -z $LOGEXT ]
then  
   LOGEXT=".log"
fi

FILE="$LOGDIR/$archivo$LOGEXT"

if [ -z $FILE ]
then
	echo -e $MODO_DE_USO
	exit 1
fi

if [ -z $ultimasLineas ]
then
	contentFile=`cat $FILE`
else
	contentFile=`tail -n $ultimasLineas $FILE`
fi

if [ -z "$cadenaABuscar" ]
then
	echo "$contentFile"
else
	echo "$contentFile" | grep "$cadenaABuscar"
fi