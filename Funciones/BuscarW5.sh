#bin/bash
#
#	Se necesita las siguientes variables definidas en el ambiente
#   antes de ejecutarse
#	$MAEDIR $ACEPDIR $RECHDIR $PROCDIR $BINDIR $CONFDIR $GRUPO
#	SECUENCIA2 : secuenciador para el ciclo buscar
#
ARCHPATRONES=$MAEDIR/patrones
CICLO=2
echo $MAEDIR


CANT_ARCH_CON_HALLASGOS=0
CANT_ARCH_SIN_HALLASGOS=0
CANT_ARCH_SIN_PATRON=0

loguear() {
	echo "$1"
}

function validarProceso {
	if [ $(ps -a | grep $1 | grep -v grep | wc -l | tr -s "\n") -gt 2 ]; then
		MYPID=`pidof -x $1`
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "$1 ya esta siendo ejecutado [${MYPID}]"
		CORRIENDO=true
	else 
		# El proceso no esta corriendo
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "OK"
	fi
}

marcarInicio() {
	CANT_ARCH=$(ls -1 $ACEPDIR | wc -l)
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Inicio BuscarW5 - Ciclo Nro.: $CICLO - Cantidad Archivos: $CANT_ARCH"
}

verificarIni() {
	#inicializo las variables para usarlas
	PROCESO=`basename $0`
	CORRIENDO=false

	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Chequeando si el proceso ya esta siendo ejecutado..."
	export CORRIENDO
	validarProceso $PROCESO
	if $CORRIENDO; then	
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "BuscarW5 ya se esta ejecutando"
		exit 1
	fi
}

finalizarProceso(){
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Fin del Ciclo: $CICLO"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos con Hallasgos: $CANT_ARCH_CON_HALLASGOS"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos sin hallasgos: $CANT_ARCH_SIN_HALLASGOS"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos sin Patron: $CANT_ARCH_SIN_PATRON"
	CICLO=$((CICLO+1))
	local user=`whoami`
	local fecha=`date '+%x %X'`
	local nl=$(grep -n '^SECUENCIA2' $CONFDIR/InstalaW5.conf | head -1 | cut -d: -f1)
	sed "${nl}s/.*/SECUENCIA2=$CICLO=$user=$fecha/" $CONFDIR/InstalaW5.conf > InstalaW5.conf.aux	
	mv InstalaW5.conf.aux $CONFIR/InstalaW5.conf
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
	nroReg_actual=$nroReg_desde
	while [ $nroReg_actual -le $nroReg_hasta ]
	do
		local resultado=$(head -n $nroReg_actual $ACEPDIR"/"$archivo | tail -1)
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
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Archivo a procesar: $file"
	echo "archivo $file"
	YA_PROC=$(ls -1 "$PROCDIR" | grep -c "$file")
	if [ "$YA_PROC" -eq 1 ] 
	then
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "Este archivo ya fue procesado: $file"	
		$BINDIR/MoverW5.sh "$ACEPDIR/$file" "$RECHDIR"
	else
		sistema=$(echo $file | cut -f1 -d'_') 
		TIENE_PAT=$(grep -c "^[^,]*,[^,]*,$sistema,*" "$ARCHPATRONES")
		if [ "$TIENE_PAT" -eq 0 ]
		then
			#loguear "No hay patrones aplicables a este archivo: $file"
			bash $BINDIR/LoguearW5.sh BuscarW5.sh -E 9 "$file"
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
