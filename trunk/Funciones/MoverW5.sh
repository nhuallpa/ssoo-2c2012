#!/bin/bash
#
# parametro 1: es el path del archivo a mover
# parametro 2: es el path de directorio destino
# parametro 3: nombre comando invocador
#
# Ejemplo: 
# MoverW5.sh <archivo origen> <directorio destino> <[comando que lo invoco]>
#
# DESCRIPCION: Mueve el archivo origen al directorio destino con el mismon nombre que 
# el original agregandole al final un numero secuencial empezando por el 0 cero. 
#

ERROR_PARAMETROS=1
ERROR_ORIGEN_NO_EXISTE=2
ERROR_DESTINO_NO_EXISTE=3

origen=$1
destino=$2
comando=$3 #opcional

# chequeo el pasaje parametros obligatorios
if [ -z "$origen" ]
then
      echo "Debe ingresar un archivo de origen (Parametro 1)"
      exit $ERROR_PARAMETROS
fi

if [ -z "$destino" ]
then
      echo "Debe ingresar un archivo de destino (Parametro 2)"
      exit $ERROR_PARAMETROS
fi

# chequeo existencia del archivo de origen
if [ ! -e $origen ] 
then
	echo "El archivo de origen '$origen' NO existe"
	exit $ERROR_ORIGEN_NO_EXISTE
fi

#chequeo existencia del directorio destino
if [ ! -d "$destino" ]
then
	echo "El archivo de destino '$destino' NO existe."
	exit $ERROR_DESTINO_NO_EXISTE
fi 


#origenFamilia= el nombre del archivo para ver si hay una familia de archivos.<SEC>
origenFamilia=$(basename $origen)

#Copio el archivo: primero me fijo si existen archivos con el nombre_de_familia.<SEC> en destino
archivosfamilia=$destino"/"$origenFamilia".*"

ls -1 $archivosfamilia > /dev/null 2>&1
HAY_FAMILIA=$?

#Si HAY_FAMILIA es distinto de 0, no existe ningun archivo de la familia.<SEC> => SEC=0
if [ $HAY_FAMILIA -eq "0" ]
then
	# Para calcular la secuencia <SEC> listo archivos de la misma familia (igual nombre, distinto numero de SEC)
	# Obtengo desde el punto el nombre del archivo, me quedo solo con los numeros,
	# ordeno por numero y obtengo el valor máximo de secuencia
	SEC=`ls -1 $archivosfamilia | grep -o '\.[0-9]*$' | cut -c2-10 | sort -n | tail -1`
	let SEC=$SEC+1

	cp $origen $destino"/"$origenFamilia"."$SEC
	rm $origen
else
	cp $origen $destino"/"$origenFamilia".0"
	rm $origen
fi

# Si terminó bien el script, devuelvo 0
exit 0