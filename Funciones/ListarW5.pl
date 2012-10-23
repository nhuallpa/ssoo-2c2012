# Verifica que las variables de ambiente PROCDIR, REPODIR y MAEDIR estén disponibles.

BEGIN{
	$VARIABLES_DE_AMBIENTE_DEFINIDAS = 1;

	my $existe_procdir = exists($ENV{PROCDIR});
	my $existe_repodir = exists($ENV{REPODIR});
	my $existe_maedir  = exists($ENV{MAEDIR});

	if ( ! ( $existe_procdir and $existe_repodir and $existe_maedir ) ) {

		print "No se encuentra declarada la variable de ambiente PROCDIR.\n" if ( !$existe_procdir);
		print "No se encuentra declarada la variable de ambiente REPODIR.\n" if ( !$existe_repodir);
		print "No se encuentra declarada la variable de ambiente MAEDIR.\n"  if ( !$existe_maedir);

		$VARIABLES_DE_AMBIENTE_DEFINIDAS = 0;
	}
}

# -----------------------------------------------------------------------------#
# Invocación al programa principal.

&main(\@ARGV) if( $VARIABLES_DE_AMBIENTE_DEFINIDAS eq 1 );


# -----------------------------------------------------------------------------#
# NOTA: Sólo sirve para comandos del tipo "-X" donde X es un caracter. Se genera
# una cadena que contiene todas las opciones seleccionadas.

sub main {

	my @ARGV = @{ shift @_ };

	# Declaro las variables que se usan como separadores.
	local $SEPARADOR_GLOBALES = ',';
	local $SEPARADOR_DETALLADOS = '\+-#-\+';
	local $SEPARADOR_PATRONES = ',';
	local $SEPARADOR_SISTEMAS = ",";

	local $SEPARADOR_HASH = "@";

	local $NOMBRE_DETALLADOS = "resultados";
	local $ARCH_GLOBALES = "rglobales";
	local $ARCHIVO_CONFIGURACION = "InstalaW5.conf";
	local $SECUENCIA_ARCH_SALIDA = "SECUENCIA_ARCH_SALIDA=";

	# Inicio del script.

	foreach (@ARGV) {
	 if ( length($_) == 2 and  $_ =~ /^-/ ) {
		push(@comandosDesordenados, substr($_,1,1));
	 }
	}

	if ( $#ARGV == $#comandosDesordenados ) {
		@comandos = sort(@comandosDesordenados);

		$comandoIngresado = "-";
		foreach (@comandos) {
			$comandoIngresado .= $_;
		}
	}

	# Valido la existencia del comando ingresado.

	$error = 1;
	if ( $comandoIngresado =~ /^-h$/ ) {
		$error = imprimirAyuda();

	} else {

		$persistir = ( $comandoIngresado =~ /x/ ) ? 1:0;

	  	if ( $comandoIngresado =~ /^-rx?$/ ) {
			$error = filtroResultadosDetallados($persistir) 
		}

	  	if ( $comandoIngresado =~ /^-g?x?$/ ) {
			$error = filtroResultadosGlobales($persistir);
	  	}
	}

	if ( $error == 1 ) {
	 	print "Opción elegida inválida, invoque \"listarW5.pl -h\" para obtener ayuda.\n";
	}

	return $error;
}

# -----------------------------------------------------------------------------#

# Imprimo la ayuda

sub imprimirAyuda() {
	
	print "\n";
	print "AYUDA. Opciones disponibles:\n\n";
	print "-g\t  Procesa los archivos globales.\n";
	print "-r\t  Procesa los archivos detallados.\n";
	print "-x\t  Almacena los resultados en un archivo salida.\n";
	print "\n";
	print "\t- Las opciones -g y -r no se pueden emplear simultáneamente.\n";
	print "\t- La opción por defecto, invocación sin parámetros, es -g.\n";
	print "\n\n";
	

	return 0;
}

# -----------------------------------------------------------------------------#
# Invoca a la subrutina correspondiente a la opción seleccionada dentro de los
# resultados detallados.
#
# parámetro 1: indica si se debe persistir la información cuando vale 1.

sub filtroResultadosDetallados {

	$persistir = $_[0];
	print "Ingrese el filtro deseado a continuación: \n";

	push(@vector,"Filtrar por patrón.");
	push(@vector,"Filtrar por ciclo.");
	push(@vector,"Filtrar por nombre de archivo.");

	my $seleccion = seleccionarOpcion(@vector);

	filtrarPorPatron($persistir) 	if ( $seleccion == 1 );

	filtrarPorCiclo($persistir) 	if ( $seleccion == 2 );

	filtrarPorArchivo($persistir) 	if ( $seleccion == 3 );
	
	return 0;
}

# -----------------------------------------------------------------------------#
# Selecciona una opción de un arreglo de opciones pasada por parámetro, se
# valida que la opción ingresada sea válida.
#
# parámetro 1: recibe un arreglo que muestra por pantalla.
#
# devuele: el valor seleccionado.

sub seleccionarOpcion {
	$cant = @_;

	$seleccion = 0;
	while ( ! ($seleccion  =~ /^[1-$cant]$/ ) ) {
		
		$indice = 1;	
		print $indice++.") ".$_."\n" foreach (@_);

		print "\nOpción seleccionada: ";
		chop ($seleccion = <STDIN>);

		if ( ! ($seleccion  =~/^[1-$cant]$/ ) ) {
			print "Opción seleccionada inválida.\n";
		}

	}
	return $seleccion;	
}

# -----------------------------------------------------------------------------#
# Recibe una arreglo de opciones de la cual se puede seleccionar uno o más
# elementos.
#
# parámetro 1: un arreglo de opciones.
#
# devuelve: un arreglo de los valores seleccionado.

sub seleccionarOpciones {

	$seleccion = 0;
	@listaDeOpciones = @_;

	$continuar = 1;
	while ( $continuar == 1 ) {
		
		$indice = 1;	
		print $indice++.") ".$_."\n" foreach (@listaDeOpciones);

		print "\nOpción seleccionada: ";
		chop ($seleccion = <STDIN>);

		# Evalúo si es válida la opción seleccionada.
		@vSeleccion = split (",",$seleccion);

		$i = 0;
		$cant = @vSeleccion;
		$valido = 1;

		while ( $valido == 1 and  $i < $cant ) {

			if ( ! ( $vSeleccion[$i] =~ /^[0-9]*-?[0-9]*$/ ) ) {
				$valido = 0;
			}

			++$i;
		}

		if ( $valido == 1 ) {
			$continuar = 0;

		}else {
			print "Opción ingresada inválida, debe tener el formato X,X,X-X donde X son números.\n";
		}
	}
	return @vSeleccion;	
}

# -----------------------------------------------------------------------------#
# Define el nombre del archivo de salida en base al último archivo de salida que
# fue previamente definidio.
#
# devuelve: el nombre del nuevo archivo de salida.

sub nombreArchivoDeSalida {

	my $numeroSecuencia = 0;
	
	my $directorio = $ENV{REPODIR};

	my $CONF_DIR = $ENV{CONFDIR};

	if ( opendir(DIRH, $CONF_DIR) ) {

		if ( -r "$CONF_DIR/$ARCHIVO_CONFIGURACION" ) {

			my $arch = $CONF_DIR."/".$ARCHIVO_CONFIGURACION;

			open ( CONFHANDLER, "<$arch" );

			my @lineas = <CONFHANDLER>;

			my $i = -1;
			while ( ( $i < $#lineas ) and ( $numeroSecuencia eq 0 ) ) { ++$i;

				my $indice = index( $lineas[$i], $SECUENCIA_ARCH_SALIDA );

				if ( $indice ne -1 ){
		
					my $valor = length($SECUENCIA_ARCH_SALIDA) + $indice;
					$numeroSecuencia = substr($lineas[$i],$valor);
					chop($numeroSecuencia);
				}
			}

			close CONFHANDLER;


			open ( CONFHANDLER, ">$arch" );

			$numeroSecuencia = ( $numeroSecuencia eq 999 ) ? 1 : ($numeroSecuencia+1);
	
			if ($numeroSecuencia < 10 ) {
				$numeroSecuencia = "00".$numeroSecuencia;

			} else { if ($numeroSecuencia < 100 ) {
				$numeroSecuencia = "0".$numeroSecuencia;
			}}

			my $salida = $SECUENCIA_ARCH_SALIDA.$numeroSecuencia."\n";

			if ( $i <= $#lineas )
				{$lineas[$i] = $salida;}

			else
				{push (@lineas, $salida);}

			print CONFHANDLER @lineas;
			close CONFHANDLER;

		} else {

			print "No se puede leer el archivo de configuración\n";
		}

		close(DIRH);

	} else {

		print "No se puede leer el archivo de configuración\n";
	}

	return $directorio."/salida_".$numeroSecuencia;
}

# -----------------------------------------------------------------------------#
# Resuelve la consulta y muesta por pantalla los resultados obtenidos. De ser
# indicado persiste la información a un archivo de salida.
#
# parámetro 1: indica si debe persistirse a disco.
# parámetro 2: hash.
# parámetro 3: mensajes a ser mostrados.
# parámetro 4: tipo de consulta.
# parámetro 5: filtro.

sub resolverConsulta {

	$persistir = shift(@_);
	$hashRef   = shift(@_);
	@mensajes  = @ { shift(@_) };
	$tipoConsulta = shift(@_);
	$elem      = shift(@_);

	# Genero un listado de selección.
	@claves = sort( keys(%hash) );

	print $_."\n" foreach (@mensajes);

	# Selecciono un conjunto de elementos.
	@opciones = seleccionarOpciones(@claves);

	# Listo el conjunto de elementos por pantalla y/o archivo.
	if ($persistir == 1 ) {
		$nombreArchivo = nombreArchivoDeSalida();

		if ( ! (open(FH,">$nombreArchivo") ) ) {

			$persistir = 0;
			print "No se pudo crear el archivo de salida.\n";
		}
	}

	if ( $persistir eq 1 ) {

		print FH "Listado de resultados detallados.\n";

		print FH $_."\n" foreach (@mensajes);

		my $indice = 1;
		foreach $opcion (@opciones) {

			$posicion = index($opcion,"-",0);

			if ( $posicion == -1 ) {

				$linea = $indice.") ".$claves[$opcion-1]."\n";
				print FH $linea;
				++$indice;

			} else {
				$inicio = substr($opcion, 0, $posicion);
				$fin = substr($opcion, $posicion + 1);

				foreach ($inicio .. $fin ) {

					$linea = $indice.") ".$claves[($_-1)]."\n";
					print FH $linea;
					++$indice;
				}

			}

		}
	}

	foreach (@opciones) {

		foreach (  split("-", $_) ) {

			$nuevaClave = $claves[$_-1];
			$nuevoHash{ $nuevaClave } = $hashRef->{$nuevaClave};
			$cantidadResultados += $hashRef->{$nuevaClave};
		}
	}

	$dir = $ENV{PROCDIR};

	opendir( DH, $dir );

	print "\n Cantidad de resultados obtenidos: ".$cantidadResultados."\n\n";
	print FH "\n Cantidad de resultados obtenidos: ".$cantidadResultados."\n\n";

	$lineas = 0;
	while ( $archivo = readdir( DH ) ) {
	
		$valido = 1;

		if ( $tipoConsulta eq 1 ) {
			$valido = ( $archivo =~ /^$NOMBRE_DETALLADOS\.$patron$/ ) ? 1:0;
		}

		if (
		    ($archivo !~ /^\.\.$/) and ($archivo !~ /.*[~.]$/ ) and ($valido eq 1 )

	       	and ($archivo =~ /^$NOMBRE_DETALLADOS\./) and (-r $dir."/".$archivo ) 

		){
			open (FILE, $dir."/".$archivo);

			$lineasArchivo = 0;
			while ( $reg = <FILE> ) {

				my @camp = split($SEPARADOR_DETALLADOS, $reg);

				$str = "";

				if ( $tipoConsulta eq 1 ) { 

					$key = $camp[1]."\t".$camp[0];

					if ( exists ( $nuevoHash{$key} ) )  {

						$str = $camp[3];
					}
				}

				if ( ( $tipoConsulta eq 2) ) {

					$pos = index($archivo,".");
					$patron = substr($archivo,$pos+1);

					$key = $camp[1]."\t".$patron;

					if ( ( exists ( $nuevoHash{$key} ) ) and ( $camp[0] eq $elem) ) {

						$str = $camp[3];
					}
				}
			
				if ( ( $tipoConsulta eq 3) ){

					$pos = index($archivo,".");
					$key = substr($archivo,$pos+1);

					if ( exists ( $nuevoHash{$key} ) and ( $elem eq $camp[1]) ){

						$str = $camp[3];
					}
				}

				if ( length($str) > 0 ) {

					++$lineas;
					++$lineasArchivo;
					print "  ".$lineas.") ".$str."\n";
					print FH "  ".$lineas.") ".$str."\n";
				}
			}

			if ( $lineasArchivo > 0 ) {
				print " Se encontraron $lineasArchivo resultados en el archivo: $archivo\n\n";
				print FH " Se encontraron $lineasArchivo resultados en el archivo: $archivo\n\n";
			}

			close(FILE);
		}
	}

	print"\n";

	close(FH) if ( $persistir == 1 );
	unlink $nombreArchivo if ( $persistir == 1 and $lineas == 0 );
}

# -----------------------------------------------------------------------------#
# Filtra el archivo de resultados detallados por el patrón ingresado.
#
# parámetro 1: indica si debe persisitirse a un archivo la salida al valer 1.

sub filtrarPorPatron {

	my $persistir = $_[0];

	# Solicita se ingrese un patrón por entrada estándar.

	my $valido = 0;
	while ( $valido eq 0 ) {

		print "Ingrese el patrón a buscar.\n";
		chop( $patron = <STDIN> );

		if ( $patron =~ /^[0-9]+$/ ) {
			$valido = 1;
		} else {
			print "\nERROR: debe ingresar un valor numérico.\n";
		}
	}
	

	#Genero un hash a partir del patrón pasado por parámetro.

	my $archivosEncontrados = 0;
	my $aciertos = 0;
	my $procdir = $ENV{"PROCDIR"};	

	if ( opendir(DirH, $procdir) ) {

		while ( $archivo = readdir(DirH) ) {

			my $archivo_actual = $procdir."/".$archivo;

			if ( $archivo =~ /^$NOMBRE_DETALLADOS\.$patron[^~]?$/ and -r $archivo_actual ) {

				++$archivosEncontrados;

				open(FH, "<$archivo_actual");

				while ( $linea = <FH> ) {
					chop ($linea);

					if ( length($linea) > 0 ) {
						++$aciertos;
						@campo = split($SEPARADOR_DETALLADOS, $linea);
						$hash{$campo[1]."\t".$campo[0]} += 1;
					}
				}
				close(FH);
			}
		}

		closedir(DirH);

		# Muestro por pantalla los resultados obtenidos.

		if ( $archivosEncontrados == 0 ) {
	 	  	print "No se encontraron archivos para el patrón: ".$patron.".\n";

		} else {

			if ( $aciertos > 0 ) {

				print "\nSeleccione una opción de la lista\n\n";			

				push (@mensajes, "Filtrado por el patrón: ".$patron);;
				push (@mensajes, "   Archivo\tNúmero de ciclo\n");
				resolverConsulta( $persistir, \%hash, \@mensajes, 1, $patron) if ( $archivosEncontrados != 0 );

			} else {

				print "No se encontraron coincidencias.\n"; 
			}
		}

	} else {

		print "ERROR: No se encuentra el directorio de la variable de ambiente PROCDIR: ".$procdir."\n";
	}

	return 0;
}

# -----------------------------------------------------------------------------#

sub filtrarPorCiclo {
	$persistir = $_[0];

	$valido = 0;
	while ( $valido eq 0 ) {

		print "Ingrese el ciclo a buscar.\n";
		chop( $cicloBuscado = <STDIN> );

		if ( $cicloBuscado =~ /^[0-9]+$/ ) {
			$valido = 1;
		} else {
			print "\nERROR: debe ingresar un valor numérico.\n";
		}
	}

	#Genero el hash a partir del ciclo pasado por parámetro.

	$aciertos = 0;
	$archivosEncontrados = 0;
	$dir = $ENV{"PROCDIR"};	

	if ( opendir(DirH, $dir ) ) {

		while ( $archivo = readdir(DirH) and -r "$dir/$archivo" ) {

			if ( $archivo =~ /^$NOMBRE_DETALLADOS\..*[^~]$/ ) {

				++$archivosEncontrados;
				open(FH,"<$dir/$archivo");
						
				$patron = substr($archivo, index($archivo, ".") + 1);

				while ( $linea = <FH> ) {
					chop ($linea);

					if ( length($linea) > 0 ) {

						@campo = split($SEPARADOR_DETALLADOS, $linea);

						if ( $campo[0] eq $cicloBuscado ) {
							++$aciertos;
							$hash{$campo[1]."\t".$patron} += 1;
						}
					}
				}
				close(FH);
			}
		}

		close(DirH);

		if ( $archivosEncontrados == 0 ) {
			print "No se encontraron archivos.\n";

		} else {

			if ( $aciertos > 0 ) {
				print "\nSeleccione una opción de la lista\n\n";

				push (@mensajes, "Filtrado por el ciclo: ".$cicloBuscado);
				push (@mensajes, "   Archivo\tPatrón\n");
				resolverConsulta( $persistir, \%hash, \@mensajes, 2, $cicloBuscado) if ( $archivosEncontrados != 0 );

			} else {

				print "No se encontraron coincidencias.\n";
			}
		}

	} else {

		print "ERROR: No se encuentra el directorio de la variable de ambiente PROCDIR: ".$procdir."\n";
	}

	return 0;
}

# -----------------------------------------------------------------------------#

sub filtrarPorArchivo {
	$persistir = $_[0];

	print "filtrar por archivo.\n";

	print "Ingrese el nombre del archivo a buscar.\n";
	chop( $nombreArchivo = <STDIN> );

	#Genero el hash a partir del archivo pasado por parámetro.

	$aciertos = 0;
	$archivosEncontrados = 0;
	$dir = $ENV{"PROCDIR"};	

	if ( opendir(DirH, $dir ) ) {

		while ( $archivo = readdir(DirH) and -r "$dir/$archivo" ) {

			if ( $archivo =~ /^$NOMBRE_DETALLADOS\..*[^~]$/ ) {

				++$archivosEncontrados;

				open(FH,"<$dir/$archivo");
						
				$patron = substr($archivo, index($archivo, ".") + 1);

				$i = 0;
				while ( $linea = <FH> ) {
			
					chop( $linea );
					if ( length($linea) > 0 ) {
						@campo = split($SEPARADOR_DETALLADOS, $linea);

						if ( $campo[1] eq $nombreArchivo ) {
							++$aciertos;
							$hash{ $patron } += 1;
						}
					}
				}
				close(FH);

			}
		}
		close(DirH);

		if ( $archivosEncontrados == 0 ) {
	 	  	print "No se encontraron archivos.\n";

		} else {

			if ( $aciertos > 0 ) {
				print "\nSeleccione una opción de la lista\n\n";

				push (@mensajes, "Filtrado por el nombre de archivo: ".$nombreArchivo);
				push(@mensajes, "   Patron\n");	
				resolverConsulta( $persistir, \%hash, \@mensajes , 3, $nombreArchivo) if ( $aciertos != 0 );

			} else {

				print "No se encontraron coincidencias.\n";
			}
		}

	} else {

		print "ERROR: No se encuentra el directorio de la variable de ambiente PROCDIR: ".$procdir."\n";
	}

	return 0;
}



################################################################################
# RESULTADOS GLOBALES                                                          #

sub filtroResultadosGlobales {

	my $persistir = shift;

	print "Seleccione una opción de búsqueda: \n";
	print "\n";

	push(@opciones,"Detectar mayor cantidad de hallazgos.\n");
	push(@opciones,"Detectar cantidad de hallazgos nula.\n");
	push(@opciones,"Expresiones regulares con mayor cantidad de hallazgos.\n");
	push(@opciones,"Expresiones regulares con menor cantidad de hallazgos.\n");
	push(@opciones,"Archivos con hallazgos pertenecientes al intervalo xx-yy.\n");
	push(@opciones,"Listar hallazgos encontrados para un filtro en particular.\n");

	$seleccion = &seleccionarOpcion( @opciones );

	&resolverConsultaGlobal($seleccion, $persistir) if ( $seleccion eq 1 );
	&resolverConsultaGlobal($seleccion, $persistir) if ( $seleccion eq 2 );
	&resolverConsultaGlobal($seleccion, $persistir) if ( $seleccion eq 6 );

	if ( $seleccion eq 3 ) {

		cargarHash( 0, \%hash);
		@resultados = &filtrarValores( 5, 1, \%hash );
		imprimirResultados( $seleccion, $persistir, \@resultados, \%hash);
	}


	if ( $seleccion eq 4 ) {

		cargarHash( 0, \%hash);
		@resultados = &filtrarValores( 5, 0, \%hash );
		imprimirResultados( $seleccion, $persistir, \@resultados, \%hash);
	}

	if ( $seleccion eq 5 ) {

		my @val = &determinarLimitesIntervalo();

		if ( $#val eq 1 ) {

		    &cargarHash( 1, \%hash);

		    &filtrarPorRango( $persistir, \%hash, $val[0], $val[1]);
		    &filtrarPorRango( 0, \%hash, $val[0], $val[1]) if ( $persistir eq 1 );
		}
	}

	return 0;
}

#------------------------------------------------------------------------------#
# Imprime por pantalla o en el archivo de salida los resultados obtenidos.
#
# parámetro 1: opción elegida, 3 para mayor cantidad de Hallazgos y 4 para la
#              menor.
# parámetro 2: persiste a archivo si vale 1.
# parámetro 3: arreglo de claves de resultados a ser mostrados por pantalla
#              a través del hash.
# parámetro 4: hash empleado para mostrar los valores de las claves de los
#              resultados.

sub imprimirResultados {

	my $s	       = shift(@_);
	my $persistir  = shift(@_);
	my $resultados = shift(@_);
	my $hash       = shift(@_);

	$expr = "5 expresiones regulares con mayor cantidad de Hallazgos.\n\n" if ( $s eq 3 );
	$expr = "5 expresiones regulares con menor cantidad de Hallazgos.\n\n" if ( $s eq 4 );

	print $expr;
	print " Hallazgos\tExpresión Regular\n";
	print " $hash{$_}\t\t$_\n" foreach (@resultados);
	print "\n";

	if ( $persistir == 1 ) {

		$nombreArchivo = nombreArchivoDeSalida();

		open( FH, ">$nombreArchivo") || die "No se pudo crear el archivo de salida.\n";

		print FH $expr;
		print FH " Hallazgos\tExpresión Regular\n";
		print FH " $hash{$_}\t\t$_\n" foreach (@resultados);
		print FH "\n";	

		close FH;

		unlink $nombreArchivo if ( $#resultados < 0 );
		
	}
}

#------------------------------------------------------------------------------#
# Valida y devuelve los valores elegidos por el usuario del límite del intervalo.
#
# devuelve: un arreglo de dos posiciones con los valores correspondientes al
#           límite inferior y al límite superior.

sub determinarLimitesIntervalo {

	my $continuar = 1;
	while ( $continuar eq  1 ) {

		print "Seleccione los limites del intervalo, xx yy: ";

		chop( $cadena = <STDIN> );
		@val = split(" ",$cadena);

		if ($#val eq 1 ) {

			if ( $val[0] =~ /^[0-9]+$/ and $val[1] =~ /^[0-9]+$/ ) {

				if ( $val[0] <= $val[1] ) {

					$continuar = 0;

				} else {

					print "\nError: $val[0] mayor a $val[1].\n";
				}

		 	}else {

				print "\nError: Sólo se admiten valores numéricos.\n";
			}
		
		} else {

			print "\nError: Ingresar 2 valores numéricos separados por un espacio.\n";
		}
	}	

	return @val;
}

#------------------------------------------------------------------------------#
# Carga un hash a partir de los archivos que se encuentran dentro de la carpeta
# definida en PROCDIR.
#
# parámetro 1: define el tipo de hash,
#		con 0 hash [ expresion_regular / hallazgos ]
#		con 1 hash [ archivo / hallazgos ]
# parámtero 2: referencia del hash.

sub cargarHash {

	my $opcion = shift(@_);
	my $hash   = shift(@_);

	$PROCDIR = $ENV{PROCDIR};

	opendir(DH, $PROCDIR );

	while ( $archivo = readdir(DH) ) {

		if ( $archivo =~ /^$ARCH_GLOBALES.*[^~.]$/ and -r $PROCDIR."/".$archivo ) {

			open(FH,"<".$PROCDIR."/".$archivo );

		
			if ( $opcion eq 0 ) {

				while ( $linea = <FH> ) {
					chop ($linea);

					if ( length($linea) > 0 ) {
						@opciones = split( $SEPARADOR_GLOBALES, $linea );
						$hash->{ $opciones[3] } += $opciones[2];
					}
				}

				close(FH);
			}

			if ( $opcion eq 1 ) {

				while ( $linea = <FH> ) {

					@opciones = split( $SEPARADOR_GLOBALES, $linea );
					$hash->{ $opciones[1] } += $opciones[2];
				}

				close(FH);
			}
		}
	}

	closedir(DH);
}

#------------------------------------------------------------------------------#
# Muestra los archivos en los cuales se encontraron hallazgos entre los valores
# pasados por parámetros correspodientes a los límites inferior y superior.
#
# parámetro 1: indica si debe persistirse o no, 1 en caso afirmativo o 0 por pantalla.
# parámetro 2: referencia del hash del tipo [ archivo / cantidad de hallazgos ].
# parámetro 3: límite inferior del rango.
# parámetro 4: límite superior del rango.

sub filtrarPorRango {

	my $persistir	    = shift(@_);
	my %hash 	    = %{ shift(@_) };	
	my $limite_inferior = shift(@_);
	my $limite_superior = shift(@_);

	my $hallazgos = 0;

	print "Archivos con expresiones en el rango $limite_inferior - $limite_superior .\n";
	print "\n Archivo\t\tHallazgos\n";

	foreach ( keys ( %hash ) ) {

		$valor = $hash{$_};

		if ( $valor >= $limite_inferior and $valor <= $limite_superior ) {

			print " $_\t$valor\n";
			++$hallazgos;
		}
	}

	print "\n-No se encontraron registros.\n" if ( $hallazgos eq 0 );
	print "\n";

	if ( $persistir eq 1 ) {

		$hallazgos = 0;
		$nombre_archivo = nombreArchivoDeSalida();
		if ( open( FH, ">$nombre_archivo") ) {

			print FH "Archivos con expresiones en el rango $limite_inferior - $limite_superior .\n";
			print FH "\n Archivo\t\tHallazgos\n";

			foreach ( keys ( %hash ) ) {

				$valor = $hash{$_};

				if ( $valor >= $limite_inferior and $valor <= $limite_superior ) {

					print FH " $_\t$valor\n";
					++$hallazgos;
				}
			}

			close FH;
		}

		unlink $nombre_archivo if ( $hallazgos eq 0 );
	}

}

#------------------------------------------------------------------------------#
# Devuelve los N primeras claves del hash ordenadas según los valores de sus
# respectivas claves, dependiendo del parámetro pasado será en orden ascendente
# o descendente.
#
# parametro 1: cantidad de valores a filtrar
# parámetro 2: debe valer 1 si se ordenan en forma ascendente y otro valor para
#	       ser ordenado en forma descendente.
# parámetro 3: el hash
#
# Devuelve un array con N claves del hash.

sub filtrarValores {

	my $limite = shift(@_);
	my $orden = shift(@_);
	local $hash = shift(@_);

	local @vector;
	my @claves = keys ( %{ $hash } );

	my $cant = @claves;

	$limite = $cant if ( $cant < $limite );
	
	for ( my $i = 0; $i < $limite; ++$i) {
		push(@vector, $claves[$i]);
	}

	&burbujeo($orden, $hash, \@vector);

	for ( my $i = $limite; $i < $cant; ++$i ) {

		push(@vector, $claves[$i]);
		&burbujeo($orden, $hash, \@vector);
		pop(@vector);
	}

	return (@vector);
}

#------------------------------------------------------------------------------#
# Ordena un vector de claves de un hash, según el orden que se indique.
#
# parámetro 1: orden en que se ordena el vector. 1 ascendente, otro #descendente.
# parámetro 2: referencia al hash.
# parámetro 3: referencia al vector a ordenar.

sub burbujeo {

	my $orden  = shift(@_);
	my $hash   = shift(@_);
	my $vector = shift(@_);

	my $limite = @vector;

	if ( $orden eq 1 ) {

		for ( my $f = 0; $f < $limite; ++$f ) {
			for ( my $m = $f+1; $m < $limite; ++$m ){

				if ( $hash->{$vector[$f]} < $hash->{$vector[$m]} ) {

					my $aux = $vector[$f];
					$vector[$f] = $vector[$m];
					$vector[$m] = $aux;
				}
			}
		}

	} else {

		for ( my $f = 0; $f < $limite; ++$f ) {
			for ( my $m = $f+1; $m < $limite; ++$m ){

				if ( $hash->{$vector[$f]} > $hash->{$vector[$m]} ) {

					my $aux = $vector[$f];
					$vector[$f] = $vector[$m];
					$vector[$m] = $aux;
				}
			}
		}

	}
}

#------------------------------------------------------------------------------#
# EXPRESIONES GLOBALES

# Evalua una expresión ingresada por la entrada estándar y determina su validez.
# En caso que sea válida, devuelve en los arreglos de las referencias pasados
# por parámetro los valores correspondientes.
#
# parámetro 1: es una referencia a un arreglo de operadores.
# parámetro 2: es una referencia a un arreglo de funciones lógicas.
#
# devuelve: el comando ingresado.

sub evaluar_expresion {

	my $operandos = shift(@_);
	my $flogicas  = shift(@_);

	my $tipoExpresion = 0;
	my $copia_comando = "";

	while ( $tipoExpresion eq 0 ) { 

		print "Escriba un comando a continuación o -h para ayuda:";
		chop ( $comando = <STDIN> );

		$copia_comando = $comando;
	
		# valido un único comando

		if ( $comando =~ /^ *-h *$/ ) {
			print "\n";
			print "El comando a ingresar puede filtrar por sistemas y/o archivos y/o patrones.\n";
			print "Se emplean los parámetros \"s\" para sitemas, \"a\" para archivos y \"p\" para patrones.\n";
			print "Estos variables se pueden conectar lógicamente mediante \"y\" e \"o\"\n";
		}

		if ( $comando =~ /^ *[psa] *$/ ) {

			$tipoExpresion = &validarExpresion ( $comando, $operandos, $flogicas);
		}

		# valido un par de comandos
		
		if ( $tipoExpresion eq 0 and $comando =~ /^ *[psa] *[oy] *[psa] *$/ ) {

			$tipoExpresion = &validarExpresion ( $comando, $operandos, $flogicas);
		}

		# valido tres comandos
		
		if ( $tipoExpresion eq 0 and $comando =~ /^ *[psa] *[oy] *\( *[psa] *[oy] *[psa] *\) *$/ ) {

			$tipoExpresion = &validarExpresion ( $comando, $operandos, $flogicas);
		}

		if ( $tipoExpresion eq 0 and $comando =~ /^ *\( *[psa] *[oy] *[psa] *\) *[oy] *[psa] *$/ ) {

			$tipoExpresion = &validarExpresion ( $comando, $operandos, $flogicas);
		}

		print "Comnado ingresado inválido.\n" if ( $tipoExpresion eq 0 );
	}

	return $copia_comando;
}

#------------------------------------------------------------------------------#
# Valida la expresión ingresada pasada por parámetro.
# En caso que sea válida, devuelve en los arreglos de las referencias pasados
# por parámetro los valores correspondientes.
#
# parámetro 1: es el comando a evaluar.
# parámetro 2: es una referencia a un arreglo de operadores.
# parámetro 3: es una referencia a un arreglo de funciones lógicas.
#
# devuelve: un valor correspondiente al tipo de expresión detectada:
#           tipo 1: x
#           tipo 2: x o x
#           tipo 3: x o ( x o x )
#           tipo 4: ( x o x ) o x
#
# donde las x pueden valer p, a o s y las o o u y.

sub validarExpresion {

	my $comandos  = shift(@_);
	my $ops = shift(@_);
	my $f 	= shift(@_);

	my $tipoExpresion = 0;

	$aux     = $comando;
	$comando =~ s/[^psaoy]*([psa])[^psaoy]*([oy]?)[^psaoy]*([psa]?)[^psaoy]*([oy]?)[^psaoy]*([psa]?).*/$1 $2 $3 $4 $5/;

	@v = split ( " " , $comando );
	$cant = @v;

	if ( ( $cant > 0 ) and ( $cant < 6 ) ) {

		$tipoExpresion = $cant;
		$tipoExpresion = 4 if ( $aux =~ /^ *\(.*$/ );

		my $i = -1;
		foreach $e (@v) { ++$i;

			(($i % 2 ) eq 0 ) ? push(@{$ops}, $e) : push(@{$f}, $e);
		}

	} else {

		print "Cantidad de operandos inválida.\n";
	}


	# evaluo si hay elementos repetidos.
	my $repetido = 0;
	my %hashOps;
	foreach $e (@{$ops} ) {

		( exists( $hashOps{$e} ) ) ? $repetido++ : ( $hashOps{$e} = 1 );
	}

	if ( $repetido ne 0 ) {

		print "ERROR: Operandos duplicados\n";
		$tipoExpresion = 0;
	}

	# genero vectores de funciones y operandos diferentes que permiten operar mejor.
	if ( $tipoExpresion eq 3 ) {

		push( @{$ops}, shift @{$ops});
		push( @{$f}  , shift @{$f}  );
	}


	#agrego un valor lógico o para poder realizar las operaciones.
	unshift( @{$f}, "o");

	#devuelvo el tipo de expresión
	return	$tipoExpresion;
}


# -----------------------------------------------------------------------------#
# Valida una lista de patrones ingresada desde entrada estándar. Se verifica la
# existencia de los patrones en el archivo maestro de patrones.
#
# devuelve: un arreglo de patrones válidos.

sub validarPatrones {

	my $validez = 0;
	my $SEP = ",";

	while ( $validez eq 0 ) {

		print "Ingrese una lista de patrones separados por $SEP o * para todos los valores.\n";
		chop ( $patrones = <STDIN> );

		@patrones = split($SEP, $patrones);

		$cant =  0;

		foreach (@patrones) {

			$_ =~ s/^ *([0-9]) *$/$1/;
			++$cant if ( $_ =~ /^[0-9]*$/ );
		}

		if ( ( $cant eq ( $#patrones +1 ) ) and ( $cant > 0 ) ) {

			$validez = 1;
		}

		if ( $patrones =~ /^\*$/ ) {

			my $dir = $ENV{MAEDIR};

			opendir( DH, $dir ) || die "No se encuentra el directorio de la variable de ambiente MAEDIR: ".$dir."\n";

			if ( -r $dir."/patrones" ) {

				open( FH, $dir."/patrones" );

				while ( $linea = <FH> ) {

					chop($linea);

					if ( length($linea) > 0 ) {

						@campos = split($SEPARADOR_PATRONES,$linea);
						push (@patrones, $campos[0] );
					}
				}
				close ( FH );
			} else {
				die "No se puede leer el archivo de patrones.\n";
			}

			closedir(DH);

			$validez = 1;
		}

	}
	return @patrones;
}

# -----------------------------------------------------------------------------#
# Valida una lista de sistemas ingresada desde entrada estándar y las devuelve 
# en un arreglo de sistemas que fueron validados contra el archivo maestro de 
# sistemas.
#
# devuelve: un arreglo de sistemas.

sub validarSistemas {

	&cargarSistemas(\%hashSistemas);

	my $SEP = ",";
	my $validez = 0;
	my $sistemas ="";

	while ( $validez eq 0 ) {

		print "Ingrese una lista de sistemas serparados por \"$SEP\" o * para todos los sistemas.\n";
		chop ( $sistemas = <STDIN> );

		@sistemas = split($SEP, $sistemas);

		if ( $sistemas =~ /^\*$/ ) {

			$validez = 1;
			push( @sistemas, $_) foreach ( keys (%hashSistemas) );
		}

		else {

			$cant = 0;
			foreach (@sistemas) {

				$_ =~ s/^ *([^ ].*[^ ]) *$/$1/;
				if ( exists( $hashSistemas{$_} ) ) {

					++$cant;	
				} else {

					print "ERROR: ".$_." no es un sistema registrado.\n";
				}
			}

			$validez = 1 if ( $cant eq ($#sistemas +1) );
		}

	}

	return @sistemas;
}

# -----------------------------------------------------------------------------#
# Carga los sistemas desde el archivo maestro en el hash pasado por parámetro.
#
# parámetro 1: referencia al hash donde se cargarán los sistemas.

sub cargarSistemas {

	my $hash = shift (@_);

	$MAEDIR = $ENV{MAEDIR};

	$archivo = "sistemas";

	if ( opendir( DH, $MAEDIR) ) {

		if ( -r $MAEDIR."/".$archivo) {

			open ( FH, $MAEDIR."/".$archivo);

			while ( $linea = <FH> ) {

				chop ( $linea );

				@campos = split ( $SEPARADOR_SISTEMAS , $linea );
				$hash->{$campos[0]} = 1;
			}

			close (FH);
		}

		closedir(DH);
	} else {

		print "No se encuentra el directorio de la variable MAEDIR: ".$MAEDIR."\n";
	}
}


# -----------------------------------------------------------------------------#
# Valida la lista de nombres de archivos ingresado desde la entrada estándar.
#
# devuelve: un arreglo con la lista de archivos.

sub validarArchivos {

	$SEP = ",";

	$validez = 0;
	while ( $validez eq 0 ) {

		print "Ingrese una lista de archivos serparados por \"$SEP\" o \"*\" para todos los archivos.\n";
		chop ( $archivos = <STDIN> );

		if ( $archivos =~ /^\*$/ ) {

			$validez = 1;
			push (@archivos, "*");
		} else {

			@archivos = split($SEP, $archivos);

			foreach (@archivos) {
				$_ =~ s/^ *([^ ].*[^ ]) *$/$1/;		
			}

			$validez = 1;
		}
	}

	return @archivos;
}

# -----------------------------------------------------------------------------#
# Resuelve la consula a partir de una expresión lógica ingresada.
#
# parámetro 1: seleccion elegida ( son válidos los valores 1,2 y 6).
# parámetro 2: opción de persistencia, debe valer 1 para persistirse la salida 
#              en un archivo.

sub resolverConsultaGlobal {

	my $seleccion = shift (@_);
	my $persistir = shift (@_);

	my @operandos;
	my @flogicas;

	my $comando = &evaluar_expresion(\@operandos, \@flogicas);

	foreach $operando (@operandos) {

		local @patrones = &validarPatrones if ( $operando eq "p" );
		local @sistemas = &validarSistemas if ( $operando eq "s" );
		local @archivos = &validarArchivos if ( $operando eq "a" );
	}

	my $dir = $ENV{PROCDIR};

	#genero hashes por cada una de las listas.

	local %patrones;
	local %sistemas;
	local %archivos;

	$patrones{$_} = 1 foreach (@patrones);
	$sistemas{$_} = 1 foreach (@sistemas);
	$archivos{$_} = 1 foreach (@archivos);

	if ( opendir( dirHandler, $dir ) ) {

		while ( $archivo = readdir( dirHandler) ) {

			if ( $archivo !~ /[\.~]$/ and $archivo !~ /^\.\.$/ and $archivo =~ /^$ARCH_GLOBALES\./) {

				$dir_archivo = $dir."/".$archivo;

				if ( -r $dir_archivo ) 

					{&evaluarArchivo( $dir, $archivo, \%hash,\@operandos, \@flogicas ) ;}
			}
		}

		closedir( dirHandler );

		if ( $seleccion eq 6 ) 

			{&imprimirResultadosSeleccionSeis(\%hash, $comando, $persistir);}

		else
			{&imprimirResultadosDeConsultaGlobal(\%hash, $seleccion, $comando, $persistir);}
	}
	
	else 
		{print "No se encontró el directorio de la variable de ambiente PROCDIR: $dir\n";}

}

# -----------------------------------------------------------------------------#
# Imprime por pantalla y/o archivo los resultados de la opción 6 del menú de 
# resolución de consultas globales.
#
# parámetro 1: referencia del hash cargado con los resultados.
# parámetro 2: expresión lógica ingresada desde entrada estándar.
# parámetro 3: opción de persistencia, debe valer 1 para habilitar la escritura
#              del archivo en disco.

sub imprimirResultadosSeleccionSeis {

	my $hash      = shift @_;
	my $comando   = shift @_;
	my $persistir = shift @_;

	my $mensaje;

	$mensaje = "Hallazgos\tOperandos\t\n";	

	foreach $clave ( sort( keys(%hash) ) ) {

		my $i = -1;
		my @elementos = &obtenerElementos($clave);

		$mensaje = $mensaje.$hash->{$clave}."\t\t";
		foreach $elemento (@elementos) { ++$i;

			if ( length( $elemento) > 0 ) {

				$mensaje = $mensaje."p: $elemento\t" if ($i eq 0);
				$mensaje = $mensaje."s: $elemento\t" if ($i eq 1);
				$mensaje = $mensaje."a: $elemento\t" if ($i eq 2);
			}
		}
		$mensaje = $mensaje."\n";
	}

	print $mensaje;

	if ( $persistir eq 1 ) {

		$encabezado = "Listado de hallazgos encontrados para un filtro en particular.\n";
		&imprimirEnArchivo($encabezado, $mensaje, $comando);
	}
}

# -----------------------------------------------------------------------------#
# Imprimir los resultados obtenidos en un archivo.
#
# parámetro 1: referencia del hash
# parámetro 2: seleccion 
# parámetro 3: expresión lógica ingresada
# parámetro 4: opción de persistencia, 1 para persistir la salida

sub imprimirResultadosDeConsultaGlobal {

	my $hash 	= shift @_;
	my $seleccion 	= shift @_;
	my $comando	= shift @_;
	my $persistir	= shift @_;

	# Ordeno las claves del hash
	my $cantValores = 3;
	my $orden = ( $seleccion eq 1 ) ? 1 : 0 ;
	@refOrdenadas = &filtrarValores( $cantValores, $orden, \%hash);

	# Obtengo el valor máximo o mínimo y calculo si hay repeticiones.
	$max = ( $#refOrdenadas >= 0 ) ? $hash{$refOrdenadas[0]} : -1 ;

	my $repeticiones = -1;

	foreach (@refOrdenadas)

		{ ++$repeticiones if ( $max eq $hash{$_} ); }

	if ( ($#refOrdenadas >= 0 ) and ( $repeticiones eq 0 ) and ( ( $seleccion eq 1 ) or ( $seleccion eq 2) and ( $max eq 0 ) ) ){

		$mensaje = "La máxima cantidad de hallazgos resultó ser: $max \n" if ( $seleccion eq 1 );

		$mensaje = "Se encontró un registro cuyo total de hallazgos es nulo.\n" if ( $seleccion eq 2 );			

		my @elementos = obtenerElementos( $refOrdenadas[0] );

		$mensaje = $mensaje."En el archivo global: ".$ARCH_GLOBALES.".".$elementos[0]."\n" if ( length($elementos[0]) > 0 );
		$mensaje = $mensaje."Correspondiente al sistema: ".$elementos[1]."\n"if ( length($elementos[1]) > 0 );
		$mensaje = $mensaje."Correspondiente al archivo: ".$elementos[2]."\n"if ( length($elementos[2]) > 0 );

	} else {

		# Comienzo a describir los mensajes de los resultados.
		$mensaje = "No se hallaron coincidencias.\n" if ( $#refOrdenadas < 0 );

		$mensaje = "No hay un único valor máximo.\n" if ( ( $repeticiones > 0 ) and ( $seleccion eq 1 ) );

		$mensaje = "No hay un único valor nulo.\n"   if ( ( $repeticiones > 0 ) and ( $seleccion eq 2 ) );

		$mensaje = "No se encontraron registros cuyo total de hallazgos sea nulo.\n" if ( ( $max ne 0 ) and ( $seleccion eq 2 ) );

		$mensaje = "Se encontraron más de un registro cuyo total de hallazgos es nulo.\n" if ( ( $repeticiones > 0 ) and ( $max eq 0 ) and ( $seleccion eq 2 ) );
	}

	# imprimo los mensajes por pantalla y archivo.
	print $mensaje;

	if ( $persistir eq 1 ) {

		$encabezado = "Consultar donde se produjo la mayor cantidad de hallazgos.\n" if ( $seleccion eq 1 );
		$encabezado = "Consultar si hubo hallazgos nulos.\n" if ( $seleccion eq 2 );

		&imprimirEnArchivo($encabezado, $mensaje, $comando);
	}
}

# -----------------------------------------------------------------------------#
# Imprime el resultado obtenido en un archivo, requiere el mensaje y el comando
# ingresado.
#
# parámetro 1: encabezado a imprimir.
# parámetro 2: mensaje a imprimir.
# parámetro 3: comando a imprimir.

sub imprimirEnArchivo {

	my $encabezado = shift @_;
	my $mensaje    = shift @_;
	my $comando    = shift @_;

	$nombreArchivo = nombreArchivoDeSalida();
	open( FH, ">$nombreArchivo") || die "No se pudo crear el archivo de salida.\n";

	print FH $encabezado;
	print FH "\nExpresión lógica: ";

	$comando =~ s/o/ o /g;
	$comando =~ s/y/ y /g;
	$comando =~ s/a/ nombre de archivo /;
	$comando =~ s/p/ patron /;
	$comando =~ s/s/ sistema /;
	$comando =~ s/ +/ /g;

	print FH $comando."\n\n";

	print FH "Filtros:\n\n";

	if ( $#patrones >= 0 ) {
		print FH " Patrones: ";
		print FH "$_ " foreach (@patrones);
		print FH "\n";
	}

	if ( $#sistemas >= 0 ) {
		print FH " Sistemas: ";
		print FH "$_ " foreach (@sistemas);
		print FH "\n";
	}

	if ( $#archivos >= 0 ) {
		print FH " Nombres de archivo: ";
		print FH "$_ " foreach (@archivos);
		print FH "\n";
	}

	print FH "\nResultados:\n\n";
	print FH $mensaje;
	close FH;
}

# -----------------------------------------------------------------------------#
# Evalúa cada línea de un archivo para determinar si cumple las restricciones
# ingreadas mediante una expresión lógica. De ser así se carga el hash con los
# resultados de la cantidad de hallazgos que se encuentran dentro de cada línea.
#
# parámetro 1: es el path al directorio
# parámetro 2: es el nombre del archivo a leer.
# parámetro 3: es una referencia al hash.

sub evaluarArchivo {

	my $dir     = shift(@_);	
	my $archivo = shift(@_);
	my $hash    = shift(@_);
	my $ops	    = shift(@_);
	my $flogicas= shift(@_);

	open( fileHandler, $dir."/".$archivo );

	my $patron = substr( $archivo, index($archivo, ".")+1 );

	while( ( $linea = <fileHandler>) and ( length(chop($linea)) > 0 ) ){

		#obtengo algunos campos a partir de una linea.
		my @campos = split( $SEPARADOR_GLOBALES, $linea );

		my $hallazgos= $campos[2];
		my $filename = $campos[1];

		my $a1 = index( $filename, "|" );
		my $a2 = index( $filename, "_" );
		my $sistema = substr($filename, $a1+1, $a2-$a1-1);

		# verifico si el registro cumple con los filtros ingresados.
		$evaluacionDeOperandos{"p"} = (exists($patrones{$patron } )) ? 1:0;
		$evaluacionDeOperandos{"s"} = (exists($sistemas{$sistema} )) ? 1:0;
		$evaluacionDeOperandos{"a"} = (exists($archivos{$filename}) or exists($archivos{"*"})) ? 1:0;

		# genero un vector con los posibles campos de la clave del hash.
		my @valores;

		push( @valores, $patron  );
		push( @valores, $sistema );
		push( @valores, $filename);

		# genero la clave y la agrego al hash.
		my @claves = &generarClaves( \%evaluacionDeOperandos, $ops, $flogicas, \@valores );
		$hash->{$_} += $hallazgos foreach ( @claves );
	}
	close( fileHandler );
}

# -----------------------------------------------------------------------------#
# Dada una expresión lógica se encuentra descompuesta entre los operadores
# ($ops) y los conectores lógicos ($f) se hace una validación sobre la expresión
# y de ser válida se genera la correspondiente clave de hash a partir de los 
# valores pasados por parámetro correspondiente a cada uno de los operandos.
#
# parámetro 1: es el resultado de la evaluación de cada operando.
# parámetro 2: es el conjunto de operandos.
# parámetro 3: es la operación lógica a aplicar sobre el i-ésimo operando.
# parámetro 4: es el conjunto de valores correspondiente a cada operando.

sub generarClaves {

	my $evaluacionOperando  = shift(@_);
	my $ops			= shift(@_);
	my $f			= shift(@_);
	my $valores 	  	= shift(@_);
	
	my $i = -1;
	my $ans = 0;
	my @claves;
 
	foreach $op (@{$ops}) { ++$i;

		if ( $f->[$i] eq "o" ) {

			$ans = ( $ans or  $evaluacionOperando->{$op} );


			if ( ( $ans eq 1 ) and ( $evaluacionOperando->{$op} eq 1 ) ) {

				&generarClaveTipoO(\@claves, $valores, $op);
			}
		}

		if ( $f->[$i] eq "y" ) {

			$ans_ant = $ans;

			$ans = ( $ans and $evaluacionOperando->{$op} );

			if ( ( $ans eq 1 ) and ( $evaluacionOperando->{$op} eq 1 ) ) {

				&generarClaveTipoY(\@claves, $valores, $op);
			}

			pop(@claves) if ( ( $ans_ant eq 1 ) and ( $ans eq 0 ) );
		}
	}

	# elimino las claves si la expresión evaluada no es válida.
	@claves = () if ( $ans eq 0 );

	return @claves;
}

# -----------------------------------------------------------------------------#
# Agrega una nueva clave con el valor del campo correspondiente al operador $op
# al arreglo de claves pasadas por parámetros.
#
# parámetro 1: es una referencia a un arreglo de claves.
# parámetro 2: es una referencia a un arreglo de valores de cada operador.
# parámetro 3: es el operador.

sub generarClaveTipoO {

	my $claves  = shift(@_);
	my $valores = shift(@_);
	my $op	    = shift(@_);

	my @clave;

	push( @clave, ( $op eq "p" ) ? $valores->[0] : "" );
	push( @clave, ( $op eq "s" ) ? $valores->[1] : "" );
	push( @clave, ( $op eq "a" ) ? $valores->[2] : "" );

	push( @{$claves}, join( $SEPARADOR_HASH, @clave) );
}

# -----------------------------------------------------------------------------#
# Agrega el valor del campo correspondiente al operador $op al arreglo de claves
# pasadas por parámetros.
#
# parámetro 1: es una referencia a un arreglo de claves.
# parámetro 2: es una referencia a un arreglo de valores de cada operador.
# parámetro 3: es el operador.

sub generarClaveTipoY {

	my $claves  = shift(@_);
	my $valores = shift(@_);
	my $op	    = shift(@_);

	my $i = 0;
	foreach (@{$claves} ) {

		my @elementos = &obtenerElementos($_);

		$clave[0] = ( $op eq "p" ) ? $valores->[0] : $elementos[0];
		$clave[1] = ( $op eq "s" ) ? $valores->[1] : $elementos[1];
		$clave[2] = ( $op eq "a" ) ? $valores->[2] : $elementos[2];

		$claves->[$i++]= join( $SEPARADOR_HASH, @clave);
	}
}

# -----------------------------------------------------------------------------#
# Obtiene los elementos de una clave
#
# parámetro 1: clave
#
# devuelve: un arreglo de elementos que conforman la clave.

sub obtenerElementos {
	my $clave = shift(@_);

	my @elementos;

	my $a1 = index( $clave, $SEPARADOR_HASH);
	my $a2 = index( $clave, $SEPARADOR_HASH, $a1+1);

	push(@elementos, substr($clave, 0, $a1) );
	push(@elementos, substr($clave, $a1+1, $a2-$a1-1) );
	push(@elementos, substr($clave, $a2+1) );

	return @elementos;
}
