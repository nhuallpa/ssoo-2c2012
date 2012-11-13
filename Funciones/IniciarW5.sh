#! /bin/bash

function exportVariables {
	export BINDIR="$BINDIR"
	export MAEDIR="$MAEDIR"
	export ARRIDIR="$ARRIDIR"
	export DATASIZE="$DATASIZE"
	export RECHDIR="$RECHDIR"
	export ACEPDIR="$ACEPDIR"
	export PROCDIR="$PROCDIR"
	export LOGDIR="$LOGDIR"
	export LOGEXT="$LOGEXT"
	export LOGSIZE="$LOGSIZE"
	export REPODIR="$REPODIR"
	export GRUPO="$GRUPO"
	export CONFDIR="$CONFDIR"	
}


## Funcion que obtiene los valores por defecto de un archivo 
function getValuesFromFile {
	
	tGRUPO=`cat $1 | grep GRUPO | cut -s -d "=" -f2`
	tBINDIR=`cat $1 | grep BINDIR | cut -s -d "=" -f2`  	
	tACEPDIR=`cat $1 | grep ACEPDIR | cut -s -d "=" -f2`
	tPROCDIR=`cat $1 | grep PROCDIR | cut -s -d "=" -f2`  	
	tRECHDIR=`cat $1 | grep RECHDIR | cut -s -d "=" -f2`
  	tARRIDIR=`cat $1 | grep ARRIDIR | cut -s -d "=" -f2`
  	tMAEDIR=`cat $1 | grep MAEDIR | cut -s -d "=" -f2`
  	tREPODIR=`cat $1 | grep REPODIR | cut -s -d "=" -f2`
  	tLOGDIR=`cat $1 | grep LOGDIR | cut -s -d "=" -f2`
  	tLOGEXT=`cat $1 | grep LOGEXT | cut -s -d "=" -f2`
  	tLOGSIZE=`cat $1 | grep LOGSIZE | cut -s -d "=" -f2`
  	tDATASIZE=`cat $1 | grep DATASIZE | cut -s -d "=" -f2`
 	tCONFDIR=`cat $1 | grep CONFDIR | cut -s -d "=" -f2`

	if [ "$tGRUPO" != "" ]; then
		GRUPO="$tGRUPO"
	fi
	if [ "$tBINDIR" != "" ]; then
		BINDIR="$tBINDIR"
	fi

	if [ "$tACEPDIR" != "" ]; then
		ACEPDIR="$tACEPDIR"
	fi
	if [ "$tPROCDIR" != "" ]; then
		PROCDIR="$tPROCDIR"
	fi

	if [ "$tARRIDIR" != "" ]; then
		ARRIDIR="$tARRIDIR"
	fi
	if [ "$tRECHDIR" != "" ]; then
		RECHDIR="$tRECHDIR"
	fi
	if [ "$tMAEDIR" != "" ]; then
		MAEDIR="$tMAEDIR"
	fi
	if [ "$tREPODIR" != "" ]; then
		REPODIR="$tREPODIR"
	fi
	if [ "$tLOGDIR" != "" ]; then
		LOGDIR="$tLOGDIR"
	fi
	if [ "$tLOGEXT" != "" ]; then
		LOGEXT="$tLOGEXT"
	fi
	if [ "$tLOGSIZE" != "" ]; then
		LOGSIZE="$tLOGSIZE"
	fi
	if [ "$tDATASIZE" != "" ]; then
		DATASIZE="$tDATASIZE"
	fi
	if [ "$tCONFDIR" != "" ]; then
		CONFDIR="$tCONFDIR"
	fi

	#echo "VARIABLE BINDIR $BINDIR"
}


if [ ! $INICIO ]; #Valido que no haya sido Iniciado antes
then  
        cd ..

	CONFIG_FILE=`cat "/home/$USER/.bashrc" | grep GRUPO04_CONFIGFILE | cut -s -d "=" -f2`
	getValuesFromFile "$CONFIG_FILE"
	exportVariables

        export PATH=$PATH:$BINDIR:$MAEDIR:$ARRIDIR:$RECHDIR:$ACEPDIR:$PROCDIR:$LOGDIR:$REPODIR

       
        $BINDIR/LoguearW5.sh IniciarW5.sh -I "Inicio de Ejecución"
       
        echo -e "TP SO7508 Segundo Cuatrimestre 2012. Tema w Copyright Grupo \n Componentes Existentes: \n Librería del Sistema: "      
       
        if [ -d "$CONFDIR" ]; then       #Busca el directorio $CONFDIR
                echo -e "$CONFDIR \n" #muestra el path          
                ls "$CONFDIR"   #muestra los archivos
        else  
                "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Librería del Sistema"
                return 1        
        fi

        if [ -d "$BINDIR" ];
        then    
                echo -e "Ejecutables: $BINDIR \n "
                if [ -f "$BINDIR/DetectaW5.sh" -a -f "$BINDIR/BuscarW5.sh" -a -f "$BINDIR/ListarW5.pl" -a -f "$BINDIR/MoverW5.sh" -a -f "$BINDIR/LoguearW5.sh" -a -f "$BINDIR/MirarW5.sh"  ]; #chequea que esten todas las funciones
                then
                        ls "$BINDIR"
                else  
                        "$BINDIR/LoguearW5.sh" IniciarW5.sh -SE 7 #Error componentes faltantes
                       
                        echo -e "Listado de los componentes faltantes: \n "

                        if [ ! -f "$BINDIR/DetectaW5.sh" ]; #para imprimir cual falta
                        then
                                echo -e "DetectaW5.sh"
                        fi
                       
                        if [ ! -f "$BINDIR/BuscarW5.sh" ];
                        then
                                echo -e "BuscarW5.sh"
                        fi
                       
                        if [ ! -f "$BINDIR/ListarW5.pl" ];
                        then
                                echo -e "ListarW5.sh"
                        fi

                        if [ ! -f "$BINDIR/MoverW5.sh" ];
                        then
                                echo -e "MoverW5.sh"
                        fi
                       
                        if [ ! -f "$BINDIR/LoguearW5.sh" ];
                        then
                                echo -e "LoguearW5.sh"
                        fi
                       
                        if [ ! -f "$BINDIR/MirarW5.sh" ];
                        then
                                echo -e "MirarW5.sh"
                        fi
                       
                        "$BINDIR/LoguearW5.sh" IniciarW5.sh -I "Estado de la Instalación: INCOMPLETA \n Proceso de Inicialización Cancelado"

                        return 1
                fi
       
        fi
       
        echo -e "Archivos Maestros: "
       
        if [ -d "$MAEDIR" ];
        then    
                echo -e "$MAEDIR \n"            
                if [ -r "$MAEDIR/patrones" -a -r "$MAEDIR/sistemas" ];
                then
                        ls "$MAEDIR"
                else  
                        "$BINDIR/LoguearW5.sh" IniciarW5.sh -SE 8
                        return 1
                fi
       
        fi
       
        echo -e "Directorio de Arribo de Archivos Externos: " 
        if [ -d "$ARRIDIR" ];
        then    
                echo -e "$ARRIDIR \n"          
                ls "$ARRIDIR"
        else
                "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Archivos Externos" #falta directorio
                return 1
        fi

        echo -e "Archivos Externos Aceptados: "
        if [ -d "$ACEPDIR" ];
        then    
                echo -e "$ACEPDIR \n"          
                ls "$ACEPDIR"
        else "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Archivos Externos Aceptados"
        return 1        
        fi
       
        echo -e "Archivos Externos Rechazados: "
        if [ -d "$RECHDIR" ];
        then    
                echo -e "$RECHDIR \n"          
                ls $RECHDIR
        else "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Archivos Externos Rechazados"            
        return 1        
        fi

        echo -e "Archivos Procesados: "
        if [ -d "$PROCDIR" ];
        then    
                echo -e "$PROCDIR \n"          
                ls "$PROCDIR"
        else "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Archivos Procesados"            
        return 1
        fi

        echo -e "Reportes de salida: "
        if [ -d "$REPODIR" ];
        then    
                echo -e "$REPODIR \n"          
                ls "$REPODIR"
        else "$BINDIR/LoguearW5.sh" IniciarW5.sh -E 3 "Reportes de Salida"              
        return 1        
        fi

        echo -e "Logs de Auditoria del Sistema: $LOGDIR/IniciarW5$LOGEXT \nEstado del sistema: INICIALIZADO"

       
	
       
        if [ `ps -ef | grep -c DetectaW5.sh` -eq 1 ]; #para saber si el demonio está corriendo (si vale 1 no está corriendo)
        then            
                nohup "$BINDIR/DetectaW5.sh"  > /tmp/stdoutDetecta.txt 2> /tmp/stderrDetecta.txt & #correr en background
        fi
       
        sleep 2s #espera
              

 
        if [ `ps -ef | grep -c DetectaW5.sh` -gt 1 ]; #para saber si se inicializo el demonio en forma correcta
        then
                echo "Demonio corriendo bajo el número: `ps -ef | grep DetectaW5.sh |grep -v 'grep'|grep -o '[0-9]*' |sed 1q`"
                $BINDIR/LoguearW5.sh IniciarW5.sh -I "Demonio corriendo bajo el número: `ps -ef | grep DetectaW5.sh |grep -v grep|grep -o '[0-9]*' |sed 1q`"
                #para saber el número busco las lineas de ps que tengan Detecta, que no tengan grep. Me quedo con los numeros con -o y con el sed devuelve solo la primer linea
        fi
	export INICIO=1 #seteo INICIO en 1, el proceso se Inició correctamente.
        echo -e "Proceso de Instalación Concluido"
        $BINDIR/LoguearW5.sh IniciarW5.sh -I "Proceso de Instalación Concluido"

        return 0        
else
        echo -e "No es posible reinicializar el sistema \n Proceso de Inicialización Cancelado" # variable INICIO esta en 1
        return 1        
fi


