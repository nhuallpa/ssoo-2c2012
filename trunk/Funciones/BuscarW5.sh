#!/bin/bash
MAEDIR=../MAEDIR
ARCHPATRONES=$MAEDIR/patrones
ACEPDIR=../ACEPDIR
PROCDIR=../PROCDIR
RECHDIR=../RECHDIR
CICLO=$SECUENCIA2

loguear() {
	echo "$1"
}

marcarInicio() {
	CANT_ARCH=$(ls -1 $ACEPDIR | wc -l)
	loguear "Inicio BuscarW5 - Ciclo Nro.: $CICLO - Cantidad Archivos: $CANT_ARCH"
}

verificarIni() {

# Verificar q ambiente este inicializado
# Verificar que no halla otro BuscarCorriendo
	if [ -z "$SECUENCIA2" ] 
	then
		loguear "Sistema no instalado"
		exit 1
	fi

	EJECUTANDO=$(ps | grep -c 'BuscarW5')
	if [ $EJECUTANDO -eq 2 ] 
	then
		PS_ID=`pidof bash`
	else	
		loguear "BuscarW5 ya se esta ejecutando"
		exit 1
	fi
}

grabarResultado(){
	local nombreArchivo=$1
	local numeroReg=$2
	local resultado=$3
	
	echo "result: $resultado"
	return 0
}

registrarLineas(){
	local archivo=$1 
	local exp=$2 
	local desde=$3 
	local hasta=$4
	local cantHallasgos=$5

	echo "registrar lineas"
}
registrarGlobales() {
	local ciclo=$1
	local archivo=$2 
	local hallasgo=$3 
	local exp=$4 
	local contexto=$5  
	local desde=$6 
	local hasta=$7
	echo "registrar globales"
}


verificarIni
marcarInicio

for file in $(ls $ACEPDIR)
do
	loguear "Archivo a procesar: $file"

	YA_PROC=$(ls -1 "$PROCDIR" | grep -c "$file")
	if [ "$YA_PROC" -eq 1 ] 
	then
		loguear "Este archivo ya fue procesado: $file"	
		./MoverW5.sh "$ACEPDIR/$file" "$RECHDIR"
	else
		sistema=$(echo $file | cut -f1 -d'_') 
#		echo $sistema
		TIENE_PAT=$(grep -c "^[^,]*,[^,]*,$sistema,*" "$ARCHPATRONES")
		if [ "$TIENE_PAT" -eq 0 ]
		then
			loguear "No hay patrones aplicables a este archivo: $file"
		else
			for regMae in $(grep $sistema $ARCHPATRONES | cut -f 1,4-6 -d',')
			do
				PAT_ID=$(echo "$regMae" | cut -f1 -d',')
				PAT_CON=$(echo "$regMae" | cut -f2 -d',')
				PAT_DESDE=$(echo "$regMae" | cut -f3 -d',')
				PAT_HASTA=$(echo "$regMae" | cut -f4 -d',')
				PAT_RE=$(grep "^$PAT_ID," "$ARCHPATRONES" | cut -f2 -d',' | sed 's/'\''//g' )
				if [ "$PAT_CON" = "linea" ]; then 
					echo "************* por linea"
					echo "patron: $PAT_RE"
					hallasgos=$(grep -c "$PAT_RE" $ACEPDIR"/"$file)
					echo "aciertos: $hallasgos en " $ACEPDIR"/"$file
					registrarLineas $file "$PAT_RE" $PAT_DESDE $PAT_HASTA $hallasgos
					registrarGlobales $CICLO $file $hallasgos $PAT_EP $PAT_CON $PAT_DESDE $PAT_HASTA
				fi
				if [ "$PAT_CON" = "caracter" ]; then
					echo "************* por caracter"	
				fi
			done
		fi
	fi
done

