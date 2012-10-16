#/bin/bash
#
#	Se necesita las siguientes variables definidas en el ambiente
#   antes de ejecutarse
#	GRUPO : ruta absoluta del tp
#	SECUENCIA2 : secuenciador para el ciclo buscar
#
MAEDIR=$GRUPO/MAEDIR
ARCHPATRONES=$MAEDIR/patrones
ACEPDIR=$GRUPO/ACEPDIR
PROCDIR=$GRUPO/PROCDIR
RECHDIR=$GRUPO/RECHDIR
CICLO=$SECUENCIA2



CANT_ARCH_CON_HALLASGOS=0
CANT_ARCH_SIN_HALLASGOS=0
CANT_ARCH_SIN_PATRON=0

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

finalizarProceso(){
	loguear "Fin del Ciclo: $CICLO"
	loguear "Cantidad de Archivos con Hallasgos: $CANT_ARCH_CON_HALLASGOS"
	loguear "Cantidad de Archivos sin hallasgos: $CANT_ARCH_SIN_HALLASGOS"
	loguear "Cantidad de Archivos sin Patron: $CANT_ARCH_SIN_PATRON"
	SECUENCIA2=$((SECUENCIA2+1))
	export SECUENCIA2
	CORRIENDO=false
}
registrarResultado() {
	local archivo=$1
	local nroReg=$2
	local resultado=$3
	local pad_id=$4
	echo "$CICLO+-#-+$archivo+-#-+$nroReg+-#-+$resultado" >> $PROCDIR/resultados.$pat_id
}

registrarGlobales() {
	local archivo=$1
	local hallasgo=$2
	local exp=$3
	local contexto=$4
	local desde=$5
	local hasta=$6
	local pad_id=$7
	echo "$CICLO,$archivo,$cantHallasgos,$exp,$pat_con,$desde,$hasta" >> $PROCDIR/rglobales.$pat_id
}

grabarBloque() {
	local archivo=$1
	local nroReg=$2
	local desde_relativo=$3
	local hasta_relativo=$4
	local pad_id=$5

	local nroReg_desde=$((nroReg+desde_relativo-1))
	local nroReg_hasta=$((nroReg+hasta_relativo-1))
#	echo "$nroReg $desde_relativo y $hasta_relativo : $nroReg_desde - $nroReg_hasta"
	nroReg_actual=$nroReg_desde
	while [ $nroReg_actual -le $nroReg_hasta ]
	do
		local resultado=$(head -n $nroReg_actual $ACEPDIR"/"$archivo | tail -1)
#		echo "$nroReg_actual : $resultado"
		registrarResultado "$archivo" $nroReg_actual "$resultado" $pat_id
		nroReg_actual=$((nroReg_actual+1))
	done

}

procesarLineas(){
	local archivo=$1
	local exp=$2
	local desde=$3
	local hasta=$4
	local pat_id=$5
	local pat_con=$6
	local nroReg=0
	local cantHallasgos=0
	while read -r linea  
	do
		nroReg=$((nroReg+1))	
		local ENCONTRO=$(echo "$linea" | grep -c "$exp")
		if [ "$ENCONTRO" -eq 1 ] 
		then
			cantHallasgos=$((cantHallasgos+1))
			grabarBloque "$archivo" $nroReg $desde $hasta $pad_id
		fi
	done < $ACEPDIR"/"$archivo
	if [ $cantHallasgos -eq 0 ] 
	then
		CANT_ARCH_SIN_HALLASGOS=$((CANT_ARCH_SIN_HALLASGOS+1))
	else
		CANT_ARCH_CON_HALLASGOS=$((CANT_ARCH_CON_HALLASGOS+1))
	fi
	registrarGlobales $archivo $cantHallasgos $exp $pat_con $desde $hasta $pat_id
 
}

procesarCaracteres(){
	local archivo=$1
	local exp=$2
	local desde=$3
	local hasta=$4
	local pat_id=$5
	local pat_con=$6
	local cantHallasgos=0
	nroReg=0
	while read -r linea  
	do
		nroReg=$((nroReg+1))	
		local ENCONTRO=$(echo "$linea" | grep -c "$exp")
		if [ "$ENCONTRO" -eq 1 ] 
		then
			cantHallasgos=$((cantHallasgos+1))
			local length=$((hasta-desde+1))
			local resultado=${linea:$desde:$length}
			registrarResultado "$archivo" $nroReg "$resultado" $pat_id
		fi
	done < $ACEPDIR"/"$archivo
	if [ $cantHallasgos -eq 0 ] 
	then
		CANT_ARCH_SIN_HALLASGOS=$((CANT_ARCH_SIN_HALLASGOS+1))
	else
		CANT_ARCH_CON_HALLASGOS=$((CANT_ARCH_CON_HALLASGOS+1))
	fi
	registrarGlobales $archivo $cantHallasgos $exp $pat_con $desde $hasta $pat_id
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
		#bash $BINDIR/LoguearW5.sh -i "Este archivo ya fue procesado: $file"	
		bash $BINDIR/MoverW5.sh "$ACEPDIR/$file" "$RECHDIR"
	else
		sistema=$(echo $file | cut -f1 -d'_') 
		TIENE_PAT=$(grep -c "^[^,]*,[^,]*,$sistema,*" "$ARCHPATRONES")
		if [ "$TIENE_PAT" -eq 0 ]
		then
			#loguear "No hay patrones aplicables a este archivo: $file"
			#bash $BINDIR/LoguearW5.sh $0 -e 9 "$file"
			CANT_ARCH_SIN_PATRON=$((CANT_ARCH_SIN_PATRON+1))
		else
			for regMae in $(grep $sistema $ARCHPATRONES | cut -f 1,4-6 -d',')
			do
				PAT_ID=$(echo "$regMae" | cut -f1 -d',')
				PAT_CON=$(echo "$regMae" | cut -f2 -d',')
				PAT_DESDE=$(echo "$regMae" | cut -f3 -d',')
				PAT_HASTA=$(echo "$regMae" | sed 's/.*,\([0-9]*\).*/\1/')   # con cut tenia eof
				PAT_RE=$(grep "^$PAT_ID," "$ARCHPATRONES" | cut -f2 -d',' | sed 's/'\''//g' )
				if [ "$PAT_CON" = "linea" ]; then 
					procesarLineas $file "$PAT_RE" $PAT_DESDE $PAT_HASTA $PAT_ID $PAT_CON 
				else
					procesarCaracteres $file "$PAT_RE" $PAT_DESDE $PAT_HASTA $PAT_ID $PAT_CON
				fi		
			done
			bash $BINDIR/MoverW5.sh "$ACEPDIR/$file" "$PROCDIR"
		fi
	fi
done
finalizarProceso
