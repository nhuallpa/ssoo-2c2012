#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	4			#
#	Nombre:	DetectaW5.sh		#
#					#
#########################################


#
# 1. Verificar inicialización del ambiente y que no haya otro demonio corriendo
# 
# 2. Chequea la existencia de archivos en ARRIDIR
# 
# 3. Se ejecuta el BuscarW5.sh
#




chequeaProceso(){

  #El Parametro 1 es el proceso que voy a buscar
  PROC=$1
  PROC_LLAMADOR=$2

  #Busco en los procesos en ejecucion y omito "grep" ya que sino siempre se va a encontrar a si mismo
  # -w es para que busque coincidencia exacta en la palabra porque sino estamos obteniendo cualquier cosa.
  PID=`ps ax | grep -v $$ | grep -v grep | grep -v -w "$PROC_LLAMADOR" | grep $PROC`
  PID=`echo $PID | cut -f 1 -d ' '`
  echo $PID
  
}

agregarVariablePath(){
  #echo $PATH
  NEWPATH=`pwd`
  export PATH=$PATH:$NEWPATH
  #echo $PATH
}

chequeaFecha(){
   FECHAPRUEBA=$1
   FECHAVAL=`date -d $FECHAPRUEBA +%F 2> /dev/null`
   echo $FECHAVAL
}


chequeaTipo(){
   ARCHIVO=$1
   VAR=`file -ib "$ARRIDIR/$ARCHIVO" | cut -f 1 -d ';'`
   if ([ "$VAR" = "text/plain" ]) then
       echo 0
   else
       echo 1
   fi
}

compararFecha(){
  FECHAA=$1
  FECHAB=$2
  ANOA=`echo "$FECHAA" | cut -f1 -d'-'`
  MESA=`date -d $FECHAA +%m`
  DIAA=`date -d $FECHAA +%d` 

  ANOB=`echo "$FECHAB" | cut -f1 -d'-'`
  MESB=`date -d $FECHAB +%m`
  DIAB=`date -d $FECHAB +%d`

  if ([ $ANOA -lt $ANOB ]) then
     echo -1
  else
     if ([ $ANOA -gt $ANOB ]) then
        echo 1
     else
        if ([ $MESA -lt $MESB ]) then
             echo -1
        else
           if ([ $MESA -gt $MESB ]) then
              echo 1
           else
              if ([ $DIAA -lt $DIAB ]) then
                 echo -1
              else
                 if ([ $DIAA -eq $DIAB ]) then
                    echo 0
                 else
                    echo 1
                 fi
	      fi
           fi
        fi
     fi
  fi
}



#main()


# esto se va a comentar luego. Inicia afuera
COMANDO="DetectaW5"
LOOP=true
CANT_LOOP=1
ESPERA=5
#ARRIDIR="/home/lucas/Grupo4/ARRIDIR"
#MAEDIR="/home/lucas/Grupo4/MAEDIR"
ARCHIVO="$MAEDIR/sistemas"
HASTA=2
#grupo="/home/lucas/Grupo4"
#RECHDIR="/home/lucas/Grupo4/RECHDIR"
#ACEPDIR="/home/lucas/Grupo4/ACEPDIR"
#BINDIR="/home/lucas/Grupo4/BINDIR"
#export GRUPO="/home/lucas/Grupo4/"

#grupo=$GRUPO

if ([ ! -d $RECHDIR ]) then
#  llamar con bash al loguear
   bash LoguearW5.sh "$COMANDO" -SE 15 $RECHDIR
   exit 1
fi

if ([ ! -d "$ARRIDIR" ]) then
#  llamar con bash al loguear
   bash LoguearW5.sh "$COMANDO" -SE 14 $ARRIDIR
   exit 1
fi


#while ([ $CANT_LOOP -lt $HASTA ])
while ([ $CANT_LOOP ])
do
   if ([ -d $ARRIDIR ]) then
	IFS=$'\n'
        ARCHIVOS=`ls -p $ARRIDIR | grep -v '/$'`
        for PARAM in $ARCHIVOS
        do  

          TIPO=`chequeaTipo "$PARAM"`
	  echo "ARCHIVO: $PARAM ; TIPO: $TIPO"
	  if ([ "$TIPO" != "1" ]) then
		  case "$PARAM" in 
		  *_*-*-*) VALNAME=`echo "correcto"`;;
		  *) VALNAME=`echo "incorrecto"`;;
		  esac 

		  if ([ "$VALNAME" = "correcto" ]) then

		    #Obtengo Sucursal y mes
		    SISID=`echo "$PARAM" | cut -f 1 -d '_'`
		    FECHA=`echo "$PARAM" | cut -f 2 -d '_'`
		                
		    FECHAVALIDA=`chequeaFecha $FECHA` 

		    if ([ "$FECHAVALIDA" != "" ]) then
		       
		       if ([ -f $ARCHIVO ]) then
	 	          a=0
	    	          a=`cut -f1 -d',' $ARCHIVO | grep $SISID -n | cut -f1 -d':'`
			  if ([ $a ]) then
		             START_DATE=`head -$a $ARCHIVO | tail -1 | cut -f3 -d','`
		             END_DATE=`head -$a $ARCHIVO | tail -1 | cut -f4 -d',' | sed 's/.*,\([0-9]*\).*/\1/'` 
			     #FECHA ACTUAL PARA COMPARAR
		             DATE=`date +%F`
		             DATE=`echo "$DATE"`

			     COMPHOY=`compararFecha $FECHA $DATE`

			     if ([ "$COMPHOY" != "1" ]) then
                                 
				     FECHAVALIDA=`chequeaFecha $END_DATE` 
#				     echo "FECHA: $FECHA"
#				     echo "START_DATE: $START_DATE"
#				     echo "END_DATE: $END_DATE"    				     
#				     echo "FECHAVALIDA: $FECHAVALIDA"
				     if ( [ "$FECHAVALIDA" == "" ] ) then
				        END_DATE=$DATE
                                     else
					END_DATE=$FECHAVALIDA
				     fi

#				     echo "FECHA: $FECHA"
#				     echo "START_DATE: $START_DATE"
#				     echo "END_DATE: $END_DATE"    				     

		  		     COMPDESDE=`compararFecha $FECHA $START_DATE`
				     COMPHASTA=`compararFecha $FECHA $END_DATE`
		 
		 		     if ([ "$COMPDESDE" != "-1" ]) then
                                        if ([ "$COMPHASTA" != "1" ]) then 
					   bash MoverW5.sh "$ARRIDIR/$PARAM"  "$ACEPDIR"
					   bash LoguearW5.sh "$COMANDO" "-I" "Archivo $PARAM enviado"  
				        else
					   bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"
			 	           bash LoguearW5.sh "$COMANDO" -E 10 $PARAM  
                                        fi
                                     else
					bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"
		 	                bash LoguearW5.sh "$COMANDO" -E 21 $PARAM  
				     fi
			     else
				bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"		
				bash LoguearW5.sh "$COMANDO" -E 20 $PARAM
			     fi

		       	  else
			     bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"		
			     bash LoguearW5.sh "$COMANDO" -E 11 $PARAM
		          fi
		       else
		          bash LoguearW5.sh "$COMANDO" "-A" "No existe el archivo maestro de sistemas"
		       fi
		    else
		       bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"		
		       bash LoguearW5.sh "$COMANDO" -E 12 $PARAM
		    fi
		  else
		    bash MoverW5.sh "$ARRIDIR/$PARAM"  "$RECHDIR/"
		    bash LoguearW5.sh "$COMANDO" -E 13 $PARAM
		  fi	
	  else
	     bash MoverW5.sh "$ARRIDIR/$PARAM" "$RECHDIR/"
	     bash LoguearW5.sh "$COMANDO" -E 19 "$PARAM"
	  fi
	done
   else
     echo "No Existe $ARRIDIR!"
   fi

   let CANT_LOOP=CANT_LOOP+1

   ENRECIBIDOS=`ls -1 "$ACEPDIR" | wc -l | awk '{print $1}'`

   if ([ $ENRECIBIDOS -gt 0 ]) then
      BUSCARW5_PID=`chequeaProceso BuscarW5.sh $$`
      if [ -z "$BUSCARW5_PID" ]; then
	  bash BuscarW5.sh &
# 	  echo ""
      else
          echo "Demonio BuscarW5 ya ejecutado bajo PID: <$BUSCARW5_PID>" 
      fi
   fi

   sleep ${ESPERA}s
done

LOOP=0
   	
exit 0

