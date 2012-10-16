#! /bin/bash

if [ ! $INICIO ];
then  


######################################################## SACAR
	cd ..	
	export MAEDIR="$PWD/MAEDIR"
	export BINDIR="$PWD/BINDIR"
	export ARRIDIR="$PWD/ARRIDIR"
	export RECHDIR="$PWD/RECHDIR"
	export ACEPDIR="$PWD/ACEPDIR"
	export PROCDIR="$PWD/PROCDIR"
	export LOGDIR="$PWD/LOGDIR"
	export REPODIR="$PWD/REPODIR"
	export GRUPO="$PWD"

#########################################################

	cd $BINDIR
	cd ..
	export PATH=$PATH:$BINDIR:$MAEDIR:$ARRIDIR:$RECHDIR:$ACPDIR:$PROCDIR:$LOGDIR:$REPODIR

	
	$BINDIR/LoguearW5.sh IniciarW5.sh -I "Inicio de Ejecución"
	
	if [ `ls -lart | grep -c '^d.*CONFDIR'` -ne 0 ];
	then 	
		echo -e "$CONFDIR \n Archivos: "		
		ls $CONFDIR	
	else  
		$CONFDIR/LoguearW5.sh IniciarW5.sh -E 3 "Librería del Sistema"
		return 1	
	fi
		
	echo -e "TP SO7508 Segundo Cuatrimestre 2012. Tema w Copyright Grupo \n Componentes Existentes: \n Ejecutables: " 	
	
	if [ `ls -lart | grep -c '^d.*BINDIR'` -ne 0 ];
	then 	
		echo -e "$BINDIR Archivos: "
		if [ -f $BINDIR/DetectaW5.sh -a -f $BINDIR/BuscarW5.sh -a -f $BINDIR/ListarW5.pl -a -f $BINDIR/MoverW5.sh -a -f $BINDIR/LoguearW5.sh -a -f $BINDIR/MirarW5.sh  ]; 
		then 
			ls $BINDIR	
		else  
			$BINDIR/LoguearW5.sh IniciarW5.sh -SE 7
			
			echo -e "Listado de los componentes faltantes: "

			if [ ! -f $BINDIR/DetectaW5.sh ];
			then 
				echo -e "DetectaW5.sh"
			fi
			
			if [ ! -f $BINDIR/BuscarW5.sh ];
			then 
				echo -e "BuscarW5.sh"
			fi
			
			if [ ! -f $BINDIR/ListarW5.pl ];
			then 
				echo -e "ListarW5.sh"
			fi

			if [ ! -f $BINDIR/MoverW5.sh ];
			then 
				echo -e "MoverW5.sh"
			fi
			
			if [ ! -f $BINDIR/LoguearW5.sh ];
			then 
				echo -e "LoguearW5.sh"
			fi
			
			if [ ! -f $BINDIR/MirarW5.sh ];
			then 
				echo -e "MirarW5.sh"
			fi
			
			$BINDIR/LoguearW5.sh IniciarW5.sh -I "Estado de la Instalación: INCOMPLETA \n Proceso de Inicialización Cancelado"

			return 1
		fi
	
	fi
	
	echo -e "Archivos Maestros: "
	
	if [ `ls -lart | grep -c '^d.*MAEDIR'` -ne 0 ];
	then 	
		echo -e "$MAEDIR \n Archivos: "		
		if [ -r $MAEDIR/patrones -a -r $MAEDIR/sistemas ]; 
		then 
			ls $MAEDIR	
		else  
			$BINDIR/LoguearW5.sh IniciarW5.sh -SE 8
			return 1
		fi
	
	fi
	
	echo -e "Directorio de Arribo de Archivos Externos: "	
	if [ `ls -lart | grep -c '^d.*ARRIDIR'` -ne 0 ];
	then 	
		echo -e "$ARRIDIR \n Archivos:\n"		
		ls $ARRIDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh -E 3 "Archivos Externos"
	return 1
	fi

	echo -e "Archivos Externos Aceptados: "
	if [ `ls -lart | grep -c '^d.*ACEPDIR'` -ne 0 ];
	then 	
		echo -e "$ACEPDIR \n Archivos: \n"		
		ls $ACEPDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh -E 3 "Archivos Externos Aceptados"
	return 1	
	fi
	
	echo -e "Archivos Externos Rechazados: "
	if [ `ls -lart | grep -c '^d.*RECHDIR'` -ne 0 ];
	then 	
		echo -e "$RECHDIR \n Archivos: \n"		
		ls $RECHDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh -E 3 "Archivos Externos Rechazados"		
	return 1	
	fi

	echo -e "Archivos Procesados: "
	if [ `ls -lart | grep -c '^d.*PROCDIR'` -ne 0 ];
	then 	
		echo -e "$PROCDIR \n Archivos: \n"		
		ls $PROCDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh -E 3 "Archivos Procesados"		
	return 1
	fi

	echo -e "Reportes de salida: "
	if [ `ls -lart | grep -c '^d.*REPODIR'` -ne 0 ];
	then 	
		echo -e "$REPODIR \n Archivos: \n"		
		ls $REPODIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh -E 3 "Reportes de Salida"		
	return 1	
	fi

	echo -e "Logs de Auditoria del Sistema: $LOGDIR/IniciarW5.$LOGEXT \nEstado del sistema: INICIALIZADO"

	
	if [ `ps -ef | grep -c DetectaW5.sh` -eq 1 ];
	then 		
		nohup $BINDIR/DetectaW5.sh  > /tmp/stdoutDetecta.txt 2> /tmp/stderrDetecta.txt &
	fi 
	
	sleep 2s
		
	if [ `ps -ef | grep -c DetectaW5.sh` -gt 1 ];
	then
		echo "Demonio corriendo bajo el número: `ps -ef | grep DetectaW5.sh |grep -v 'grep'|grep -o '[0-9]*' |sed 1q`"
		$BINDIR/LoguearW5.sh IniciarW5.sh -I "Demonio corriendo bajo el número: `ps -ef | grep DetectaW5.sh |grep -v grep|grep -o '[0-9]*' |sed 1q`"
  	fi

	echo -e "Proceso de Instalación Concluido"
	export INICIO=1
	return 0	
else
	echo -e "No es posible reinicializar el sistema \n Proceso de Inicialización Cancelado"	
	return 1	
fi

	


