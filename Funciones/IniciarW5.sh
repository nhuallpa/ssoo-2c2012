#! /bin/bash

if [ ! $INICIO ];
then  
	cd ..

	export MAEDIR="$PWD/MAEDIR"
	export BINDIR="$PWD/BINDIR"
	export ARRIDIR="$PWD/ARRIDIR"
	export RECHDIR="$PWD/RECHDIR"
	export ACPDIR="$PWD/ACPDIR"
	export PROCEDIR="$PWD/PROCEDIR"
	export LOGDIR="$PWD/LOGDIR"
	export REPODIR="$PWD/REPODIR"

	
	export PATH=$PATH:$BINDIR:$MAEDIR:$ARRIDIR:$RECHDIR:$ACPDIR:$PROCDIR:$LOGDIR:$REPODIR


	$BINDIR/LoguearW5.sh IniciarW5.sh I "Inicio de Ejecucion"

		
	echo -e "TP SO7508 Segundo Cuatrimestre 2012. Tema w Copyright Grupo \n Componentes Existentes: \n Ejecutables: " 	
	
	if [ `ls -lart | grep -c '^d.*BINDIR'` ];
	then 	
		echo -e "$BINDIR \n Archivos: \n"
		if [ -f $BINDIR/DetectaW5.sh -a -f $BINDIR/BuscarW5.sh -a -f $BINDIR/ListarW5.sh -a -f $BINDIR/MoverW5.sh -a -f $BINDIR/LoguearW5.sh -a -f $BINDIR/MirarW5.sh  ]; 
		then 
			ls $BINDIR	
		else  
			$BINDIR/LoguearW5.sh IniciarW5.sh E "Faltan comandos para realizar la Inicialización:"
			
			echo -e "Listado de los componentes faltantes: "

			if [ ! -f $BINDIR/DetectaW5.sh ];
			then 
				echo -e "DetectaW5.sh"
			fi
			
			if [ ! -f $BINDIR/BuscarW5.sh ];
			then 
				echo -e "BuscarW5.sh"
			fi
			
			if [ ! -f $BINDIR/ListarW5.sh ];
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
			
			echo -e "Estado de la Instalación: INCOMPLETA \n Proceso de Inicialización Cancelado"

			return 1
		fi
	
	fi
	
	echo -e "Archivos Maestros: "
	
	if [ `ls -lart | grep -c '^d.*MAEDIR'` ];
	then 	
		echo -e "$MAEDIR \n Archivos: \n"		
		if [ -r $MAEDIR/patrones -a -r $MAEDIR/sistemas ]; 
		then 
			ls $MAEDIR	
		else  
			$BINDIR/LoguearW5.sh IniciarW5.sh E "Faltan archivos maestros para realizar la Inicialización"
			return 1
		fi
	
	fi
	
	echo -e "Directorio de Arribo de Archivos Externos: "	
	if [ `ls -lart | grep -c '^d.*ARRIDIR'` ];
	then 	
		echo -e "$ARRIDIR \n Archivos:\n"		
		ls $ARRIDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh E "Falta directorio de Arribo de Archivos Externos para realizar la Inicialización"
	return 1
	fi

	echo -e "Archivos Externos Aceptados: "
	if [ `ls -lart | grep -c '^d.*ACEPDIR'` ];
	then 	
		echo -e "$ACEPDIR \n Archivos: \n"		
		ls $ACEPDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh E "Falta directorio de Archivos Externos Aceptados para realizar la Inicialización"
	return 1	
	fi
	
	echo -e "Archivos Externos Rechazados: "
	if [ `ls -lart | grep -c '^d.*RECHDIR'` ];
	then 	
		echo -e "$RECHDIR \n Archivos: \n"		
		ls $RECHDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh E "Falta directorio de Archivos Externos Rechazados para realizar la Inicialización"		
	return 1	
	fi

	echo -e "Archivos Procesados: "
	if [ `ls -lart | grep -c '^d.*PROCDIR'` ];
	then 	
		echo -e "$PROCDIR \n Archivos: \n"		
		ls $PROCDIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh E "Falta directorio de Archivos Procesados para realizar la Inicialización"		
	return 1
	fi

	echo -e "Reportes de salida: "
	if [ `ls -lart | grep -c '^d.*REPODIR'` ];
	then 	
		echo -e "$REPODIR \n Archivos: \n"		
		ls $REPODIR
	else $BINDIR/LoguearW5.sh IniciarW5.sh E "Falta directorio de Reportes de Salida para realizar la Inicialización"		
	return 1	
	fi

	echo -e "Logs de Auditoria del Sistema: $LOGDIR/IniciarW5.$LOGEXT \nEstado del sistema: INICIALIZADO"

	
	if [ `ps -A | grep -c DetectaW5.sh` ];
	then
		$BINDIR/LoguearW5.sh IniciarW5.sh I "Demonio corriendo bajo el número: `ps -A | grep DetectaW5.sh |grep -o '^.....'`"
	fi

	echo -e "Proceso de Instalación Concluido"
	export INICIO=1
	return 0	
else
	echo -e "No es posible reinicializar el sistema \n Proceso de Inicialización Cancelado"	
	return 1	
fi

	


