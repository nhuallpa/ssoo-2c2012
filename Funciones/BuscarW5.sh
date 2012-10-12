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

function validarProceso {
	if [ $(ps -a | grep $1 | grep -v grep | wc -l | tr -s "\n") -gt 2 ]; then
		MYPID=`pidof -x $1`
		loguear "$1 ya esta siendo ejecutado [${MYPID}]"
		CORRIENDO=true
	else 
		# El proceso no esta corriendo
		loguear "OK"
	fi
}

marcarInicio() {
	CANT_ARCH=$(ls -1 $ACEPDIR | wc -l)
	loguear "Inicio BuscarW5 - Ciclo Nro.: $CICLO - Cantidad Archivos: $CANT_ARCH"
}

verificarIni() {
	#inicializo las variables para usarlas
	PROCESO=`basename $0`
	CORRIENDO=false

	# Verificar q ambiente este inicializado
	if [ -z "$SECUENCIA2" ] 
	then
		loguear "Sistema no instalado. Falta definir SECUENCIA2"
		exit 1
	fi

	loguear "Chequeando si el proceso ya esta siendo ejecutado..."
	export CORRIENDO
	validarProceso $PROCESO
	if $CORRIENDO; then	
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

finalizarProceso(){
	loguear "Fin del Ciclo: $CICLO"
	loguear "Cantidad de Archivos con Hallasgos: XXX"
	loguear "Cantidad de Archivos sin hallasgos: ZZZ"
	loguear "Cantidad de Archivos sin Patron: $1"
	let SECUENCIA2=SECUENCIA2+1
	export SECUENCIA2
}

procesarLineas(){
	local archivo=$1
	local hallasgos=$2 
	local exp=$3
	local desde=$4
	local hasta=$5
	echo "registrar lineas"
}
procesarCaracteres(){
	local archivo=$1
	local hallasgos=$2 
	local exp=$3
	local desde=$4
	local hasta=$5
	echo "registrar caracteres"
	L_CANT_HALLASGOS=0
	while read -r linea  
	do
		ENCONTRO=$(echo "$linea" | grep -c "$exp")
		if [ "$ENCONTRO" -eq 1 ] 
		then
			echo "$desde - $hasta"
			echo "$linea"
			var=$linea
			RESULTADO=${var2:desde:hasta}
			loguear $RESULTADO
		fi
	done < $ACEPDIR"/"$archivo

}
registrarGlobales() {
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
CANT_CON_HALLASGOS=0
CANT_SIN_HALLASGOS=0
CANT_SIN_PATRON=0

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
		TIENE_PAT=$(grep -c "^[^,]*,[^,]*,$sistema,*" "$ARCHPATRONES")
		if [ "$TIENE_PAT" -eq 0 ]
		then
			loguear "No hay patrones aplicables a este archivo: $file"
			let CANT_SIN_PATRON=CANT_SIN_PATRON+1		
		else
			for regMae in $(grep $sistema $ARCHPATRONES | cut -f 1,4-6 -d',')
			do
				PAT_ID=$(echo "$regMae" | cut -f1 -d',')
				PAT_CON=$(echo "$regMae" | cut -f2 -d',')
				PAT_DESDE=$(echo "$regMae" | cut -f3 -d',')
				PAT_HASTA=$(echo "$regMae" | cut -f4 -d',')
				PAT_RE=$(grep "^$PAT_ID," "$ARCHPATRONES" | cut -f2 -d',' | sed 's/'\''//g' )
				hallasgos=$(grep -c "$PAT_RE" $ACEPDIR"/"$file)
				if [ "$PAT_CON" = "linea" ]; then 
					procesarLineas $file $hallasgos "$PAT_RE" $PAT_DESDE $PAT_HASTA 
				else
					procesarCaracteres $file $hallasgos "$PAT_RE" $PAT_DESDE $PAT_HASTA 
				fi		
				registrarGlobales $file $hallasgos $PAT_RE $PAT_CON $PAT_DESDE $PAT_HASTA
			done
		fi
	fi
done
finalizarProceso $CANT_SIN_PATRON
