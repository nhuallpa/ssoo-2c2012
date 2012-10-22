#bin/bash
#########################################
#					
#	Sistemas Operativos 75.08	
#	Grupo: 	4			
#	Nombre:	BuscarW5.sh		
#										
#########################################
#
# 1. Verificar inicialización del ambiente y que no haya otro BuscarW5 corriendo
# 
# 2. Por cada archivo de ACEPDIR, busca los patrones aplicar
#
# 3. Aplica los patrones usando contexto de linea ó caracter
#
# 4. Contabiliza hallasgos y guarda resultados detallados y globales
ARCHPATRONES=$MAEDIR/patrones
CICLO=0


CANT_ARCH_CON_HALLASGOS=0
CANT_ARCH_SIN_HALLASGOS=0
CANT_ARCH_SIN_PATRON=0

mostrar() {
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
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "====================================================================="
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Inicio BuscarW5 - Ciclo Nro.: $CICLO - Cantidad Archivos: $CANT_ARCH"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "====================================================================="
	
}

verificarIni() {
	#inicializo las variables para usarlas
	PROCESO=`basename $0`
	CORRIENDO=false

	if [ -z "$INICIO" ]; then 
		mostrar "BuscarW5: Variable INICIO no definida"
		exit 1
	fi
	if [ "$INICIO" -ne 1 ]; then
		mostrar "BuscarW5: Ambiente no inicializado"
		exit 1
	fi

	CICLO=$(grep 'SECUENCIA2' $CONFDIR/InstalaW5.conf | cut -f2 -d"=")
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Chequeando si el proceso ya esta siendo ejecutado..."
	export CORRIENDO
	validarProceso $PROCESO
	if $CORRIENDO; then	
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "BuscarW5 ya se esta ejecutando"
		exit 1
	fi
	# Inicio ciclo de ejecucion	
	CICLO=$((CICLO+1))
}

finalizarProceso(){
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "============================================================="
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "					Fin del Ciclo: $CICLO"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos con Hallasgos: $CANT_ARCH_CON_HALLASGOS"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos sin hallasgos: $CANT_ARCH_SIN_HALLASGOS"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Cantidad de Archivos sin Patron: $CANT_ARCH_SIN_PATRON"
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "============================================================="

	local user=`whoami`
	local fecha=`date '+%x %X'`
	sed -i s-^SECUENCIA2.*-SECUENCIA2="$CICLO"="$user"="$fecha"- "$CONFDIR/InstalaW5.conf"
	CORRIENDO=false
}
registrarResultado() {
	local archivo=$1
	local nroReg=$2
	local resultado=$3
	local pad_id=$4
	echo "$CICLO+-#-+$archivo+-#-+$nroReg+-#-+$resultado" >> "$PROCDIR"/resultados.$pat_id
}

registrarGlobales() {
	local archivo=$1
	local hallasgo=$2
	local exp=$3
	local contexto=$4
	local desde=$5
	local hasta=$6
	local pad_id=$7
	if [ $hallasgo -eq 0 ] 
	then	
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "Archivo:$archivo - NO tiene hallasgos con PAT_ID:$pat_id"	
	else
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "Archivo:$archivo - Tiene $hallasgo hallasgos con PAT_ID:$pat_id"	
	fi

	echo "$CICLO,$archivo,$cantHallasgos,$exp,$pat_con,$desde,$hasta" >> "$PROCDIR"/rglobales.$pat_id
}
# Extrea un bloque de lineas de un archivo dependiendo
# de un numero de linea de referencia, un linea desde relativo
# y un linea hasta relativo
grabarBloque() {
	local archivo=$1
	local nroReg=$2
	local desde_relativo=$3
	local hasta_relativo=$4
	local pad_id=$5

	local cantLinArch=$(wc -l "$ACEPDIR/$archivo" | sed 's-\(^[0-9]*\).*-\1-')
	local nroReg_desde=$((nroReg+desde_relativo-1))
	local nroReg_hasta=$((nroReg+hasta_relativo-1))
	nroReg_actual=$nroReg_desde
	while [ $nroReg_actual -le $nroReg_hasta ]
	do
		if [ $nroReg_actual -le $cantLinArch ]; then # Valido que no se pase de las lineas del archivo
			local resultado=$(head -n $nroReg_actual $ACEPDIR"/"$archivo | tail -1)
			registrarResultado "$archivo" $nroReg_actual "$resultado" $pat_id
			nroReg_actual=$((nroReg_actual+1))
		else
			$BINDIR/LoguearW5.sh BuscarW5.sh -I "El bloque requerido supera las lineas totales del archivo"
			continue
		fi
	done
}
# Recorre cada linea y aplica el patron
# Por cada linea que aplica, extre un bloque de lineas en el contexto del hallago
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
	registrarGlobales $archivo $cantHallasgos $exp $pat_con $desde $hasta $pat_id
	echo "$cantHallasgos"
}

# Recorre cada linea y aplica el patron
# Por cada linea que aplica, toma el bloque de caracteres, tomando como referencia
# el primer caracter de la linea donde se produjo el hallasgas
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
	registrarGlobales $archivo $cantHallasgos $exp $pat_con $desde $hasta $pat_id
	echo "$cantHallasgos"
}

verificarIni
marcarInicio
totalArchivosDispo=$(ls -1 $ACEPDIR | wc -l)
nroArchivo=0
# empezamos a leer todos los archivos del directorio de acaptados

$BINDIR/LoguearW5.sh BuscarW5.sh -I "Se encontraron los siguiente archivo a procesar:"
$BINDIR/LoguearW5.sh BuscarW5.sh -I "$(ls -1 $ACEPDIR)"
for file in $(ls $ACEPDIR)
do
	$BINDIR/LoguearW5.sh BuscarW5.sh -I "Archivo a procesar: $file"
	# Validacmos que el archivo no este procesado
	YA_PROC=$(ls -1 "$PROCDIR" | grep -c "$file")
	if [ "$YA_PROC" -eq 1 ] 
	then
		$BINDIR/LoguearW5.sh BuscarW5.sh -I "Este archivo ya fue procesado: $file"	
		$BINDIR/MoverW5.sh "$ACEPDIR/$file" "$RECHDIR"
	else
		# Extraemos el sistema desde el nombre del archivo y validamos que tenga patrones
		sistema=$(echo $file | cut -f1 -d'_') 
		TIENE_PAT=$(grep -c "^[^,]*,[^,]*,$sistema,*" "$ARCHPATRONES")

		if [ "$TIENE_PAT" -eq 0 ]
		then
			#loguear "No hay patrones aplicables a este archivo: $file"
			bash $BINDIR/LoguearW5.sh BuscarW5.sh -E 9 "$file"
			CANT_ARCH_SIN_PATRON=$((CANT_ARCH_SIN_PATRON+1))
		else
			acumHallasgos=0

			# recorremos cada uno de los patrones encontrados
			for regMae in $(grep $sistema $ARCHPATRONES | cut -f 1,4-6 -d',')
			do
				hallasgosParciales=0
				PAT_ID=$(echo "$regMae" | cut -f1 -d',')
				PAT_CON=$(echo "$regMae" | cut -f2 -d',')
				PAT_DESDE=$(echo "$regMae" | cut -f3 -d',')
				PAT_HASTA=$(echo "$regMae" | sed 's/.*,\([0-9]*\).*/\1/')   # Extraemos solo los numeros
				PAT_RE=$(grep "^$PAT_ID," "$ARCHPATRONES" | cut -f2 -d',' | sed 's/'\''//g' ) # Extraemos las expreciones regulares sin comillas simples, porque sino no funcionaba el grep
				if [ "$PAT_CON" = "linea" ]; then 
					hallasgosParciales=$(procesarLineas $file "$PAT_RE" $PAT_DESDE $PAT_HASTA $PAT_ID $PAT_CON)
				else
					hallasgosParciales=$(procesarCaracteres $file "$PAT_RE" $PAT_DESDE $PAT_HASTA $PAT_ID $PAT_CON)
				fi		
				acumHallasgos=$((acumHallasgos+hallasgosParciales))
			done

			if [ "$acumHallasgos" -eq 0 ] 
			then	
				CANT_ARCH_SIN_HALLASGOS=$((CANT_ARCH_SIN_HALLASGOS+1))
			else
				CANT_ARCH_CON_HALLASGOS=$((CANT_ARCH_CON_HALLASGOS+1))
			fi
			
			bash $BINDIR/MoverW5.sh "$ACEPDIR/$file" "$PROCDIR"
		fi
	fi
	nroArchivo=$((nroArchivo+1))
	mostrar "($nroArchivo/$totalArchivosDispo) archivos leidos"	
done
finalizarProceso
