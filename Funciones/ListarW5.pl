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
	local $SEPARADOR_MAESTRO = ',';
	local $SEPARADOR_SISTEMAS = ",";

	local $NOMBRE_DETALLADOS = "resultados";
	local $ARCH_GLOBALES = "rglobales";

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

	$persistir = @_[0];
	print "Ingrese el filtro deseado a continuación: \n";

	push(@vector,"Filtrar por patrón.");
	push(@vector,"Filtrar por ciclo.");
	push(@vector,"Filtrar por archivo.");

	$seleccion = seleccionarOpcion(@vector);

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
	
	my $directorio = $ENV{REPODIR};

	my $numero = 0;

	if ( opendir(DIRH, $directorio) ) {

		while ( my $archivo = readdir(DIRH) ) {
	
			if ( $archivo =~ /^salida_[0-9][0-9][0-9]$/ ) {

				$archivo =~ s/salida_(.*)/\1/g;
				$numero = $archivo if ( $archivo > $numero );
			}
		}

		closedir(DIRH);

		++$numero;

		if ($numero < 10 ) {
			$numero = "00".$numero;

		} else { if ($numero < 100 ) {
			$numero = "0".$numero;
		}}

	}

	else {

		print "ERROR al abrir el directorio: ".$directorio.".\n";
	}

	return $directorio."/salida_".$numero;;
}

# -----------------------------------------------------------------------------#
# Resuelve la consulta y muesta por pantalla los resultados obtenidos. De ser
# indicado persiste la información a un archivo de salida.
#
# parámetro 1: indica si debe persistirse a disco.
# parámetro 2: hash.
# parámtero 3: mensajes a ser mostrados.

sub resolverConsulta {

	$persistir = shift(@_);
	$hashRef   = shift(@_);
	@mensajes  = @ { shift(@_) };

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

	print "\n Resultados obtenidos:\n\n";
	print FH "\n Resultados obtenidos:\n\n" if ( $persistir eq 1 );


	$lineas = 0;
	foreach $opcion (@opciones) {

		$posicion = index($opcion,"-",0);

		if ( $posicion == -1 ) {

			$linea = " ".$hashRef->{$claves[$opcion-1]};

			print $linea."\n";
			print FH $linea."\n" if ($persistir==1);
			++$lineas;

		} else {		
			$inicio = substr($opcion, 0, $posicion);
			$fin = substr($opcion, $posicion + 1);

			foreach ($inicio .. $fin ) {

				$linea = " ".$hashRef->{$claves[$_-1]};
				print $linea."\n";
				print FH $linea."\n" if ($persistir==1);
				++$lineas;
			}

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

	my $persistir = @_[0];

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
						$hash{$campo[1]."\t".$campo[0]} = $campo[3];
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
				resolverConsulta( $persistir, \%hash, \@mensajes ) if ( $archivosEncontrados != 0 );

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
	$persistir = @_[0];

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
							$hash{$campo[1]."\t".$patron} = $campo[3];
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
				resolverConsulta( $persistir, \%hash, \@mensajes ) if ( $archivosEncontrados != 0 );

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
	$persistir = @_[0];

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
							$hash{ $patron } = $campo[3];
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
				resolverConsulta( $persistir, \%hash, \@mensajes ) if ( $aciertos != 0 );

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

	$seleccion = &seleccionarOpcion( @opciones );

	&resolverConsultaGlobal($seleccion, $persistir) if ( $seleccion eq 1 );
	&resolverConsultaGlobal($seleccion, $persistir) if ( $seleccion eq 2 );

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
		    &filtrarPorRango( 0, \%hash, $val[0], $val[1]) if ( $persisir eq 1 );
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

		print "Seleccione limites del intervalo, xx yy: ";

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
	print "\n Archivo\tHallazgos\n";

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
			print FH "\n Archivo\tHallazgos\n";

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

	$limite = @claves if ( $cant < $limite );
	
	for ( my $i = 0; $i < $limite; ++$i) {
		push(@vector, $claves[$i]);
	}

	&burbujeo($orden, $hash, \@vector);

	for ( my $i = $limite +1 ; $i < $cant; ++$i ) {

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
# devuelve: un valor correspondiente al tipo de expresión detectada:
#           tipo 1: x
#           tipo 2: x o x
#           tipo 3: x o ( x o x )
#           tipo 4: ( x o x ) o x
#
# donde las x pueden valer p, a o s y las o o u y.

sub evaluar_expresion {

	my $operandos = shift(@_);
	my $flogicas  = shift(@_);

	my $tipoExpresion = 0;

	while ( $tipoExpresion eq 0 ) { 

		print "Escriba un comando a continuación o -h para ayuda:";
		chop ( $comando = <STDIN> );
	
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

	return $tipoExpresion;
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
	my $operandos = shift(@_);
	my $flogicas  = shift(@_);

	my $tipoExpresion = 0;

	$aux     = $comando;
	$comando =~ s/([psa])[^psaoy]*([oy]?)[^psaoy]*([psa]?)[^psaoy]*([oy]?)[^psaoy]*([psa]?).*/\1 \2 \3 \4 \5/;

	@v = split ( " " , $comando );
	$cant = @v;

	if ( $cant eq 1 ) {

		$tipoExpresion = 1;
		@{$operandos} = ($v[0]);
	}

	if ( ( $cant eq 3 ) and ( $v[0] ne $v[2] ) ) {
			
		$tipoExpresion = 2;

		@{$operandos} = ($v[0], $v[2]);
		@{$flogicas}  = ($v[1]);
	}

	if ( ( $cant eq 5 ) and

	   ( ( $v[0] ne $v[2] ) and ( $v[2] ne $v[4] ) and ( $v[4] ne $v[0] ) ) ) {

		$tipoExpresion = ( $aux =~ /^ *\(.*$/ ) ? 4 : 3;

		@{$operandos}  = ($v[0], $v[2], $v[4]);
		@{$flogicas} = ($v[1], $v[3]);
	}

	print "ERROR: Operandos duplicados\n" if ( $tipoExpresion eq 0 );

	return	$tipoExpresion;
}


# -----------------------------------------------------------------------------#
sub validarPatrones {

	my $validez = 0;
	my $SEP = ",";

	while ( $validez eq 0 ) {

		print "Ingrese una lista de patrones separados por $SEP o * para todos los valores.\n";
		chop ( $patrones = <STDIN> );

		@patrones = split($SEP, $patrones);

		$cant =  0;

		foreach (@patrones) {

			$_ =~ s/^ *([0-9]) *$/\1/;
			++$cant if ( $_ =~ /^[0-9]*$/ );
		}

		if ( ( $cant eq ( $#patrones +1 ) ) and ( $cant > 0 ) ) {

			$validez = 1;
		}

		if ( $patrones =~ /^*$/ ) {

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

sub validarSistemas {

	&cargarSistemas(\%hashSistemas);

	$SEP = ",";
	$validez = 0;
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

				$_ =~ s/^ *([^ ].*[^ ]) *$/\1/;
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
	}
}


# -----------------------------------------------------------------------------#
sub validarArchivos {
	$SEP = ",";

	$validez = 0;
	while ( $validez eq 0 ) {

		print "Ingrese una lista de archivos serparados por \"$SEP\"\n";
		chop ( $archivos = <STDIN> );

		@archivos = split($SEP, $archivos);

		foreach (@archivos) {
			$_ =~ s/^ *([^ ].*[^ ]) *$/\1/;		
		}

		$validez = 1;

	}

	return @archivos;
}

# -----------------------------------------------------------------------------#
sub resolverConsultaGlobal {

	my $seleccion = shift (@_);
	my $persistir = shift (@_);

	local @operandos;
	local @flogicas;

	local $tipoExpresion = &evaluar_expresion(\@operandos, \@flogicas);

	foreach $operando (@operandos) {

		local @patrones = &validarPatrones if ( $operando eq "p" );
		local @sistemas = &validarSistemas if ( $operando eq "s" );
		local @archivos = &validarArchivos if ( $operando eq "a" );
	}

	print "\n\n";

	my $dir = $ENV{PROCDIR};

	if ( opendir( dirHandler, $dir ) ) {

		while ( $archivo = readdir( dirHandler) ) {

			if ( $archivo !~ /[\.~]$/ and $archivo !~ /^\.\.$/ and $archivo =~ /^$ARCH_GLOBALES\./) {

				$dir_archivo = $dir."/".$archivo;
				&evaluarArchivo( $dir, $archivo, \%hash) if ( -r $dir_archivo );
			}
		}


		############## BORRAR ##########################################

		print "########################\n\n";
		print "valores del hash:\n";
		print "$_ | $hash{$_}\n" foreach ( keys( %hash) );
		print "########################\n\n";

		############## BORRAR ##########################################

		closedir( dirHandler );

		$orden = ( $seleccion eq 1 ) ? 1 : 0 ;
		@refOrdenadas = &filtrarValores( 5, $orden, \%hash);

		$max = $hash{@refOrdenadas[0]};

		$repeticiones = 0;
		foreach (@refOrdenadas) {

			$repeticiones += 1 if ( $max eq $hash{$_} );
		}

		if ( $#refOrdenadas < 0 ) {

			$mensaje = "No se hallaron coincidencias.\n";
		}
	
		else { 
			if ( $repeticiones > 1 ) {

				$mensaje = "No hay un único valor máximo.\n";
			}

			 else {
				if ( $seleccion eq 1 ) {
					$mensaje = "La máxima cantidad de hallazgos resultó ser: ".$hash{$refOrdenadas[0]}."\n";

					$cadena = $refOrdenadas[0];

					$posicion1 = index($cadena,"|",0);
					$posicion2 = index($cadena,"_",0);
	
					my $pat = substr( $cadena, 0, $posicion1 );
					my $sis = substr( $cadena, $posicion1+1, ($posicion2-$posicion1-1) );
					my $nom = substr( $cadena, $posicion1+1);
				

					$mensaje = $mensaje."Se encontró en: ".$ARCH_GLOBALES.".".$pat." del sistema: ".$sis;
					$mensaje = $mensaje."\nCorrespondiente al archivo: ".$nom."\n";
				}

				else {

					if ( $hash{$refOrdenadas[0]} eq 0 ) {

						$mensaje = "Se encontraron registros cuyo total de hallazgos es nulo.\n";
					} 

					else {

						$mensaje = "No se encontraron registros cuyo total de hallazgos sea nulo.\n";
					}
				}
			}
		}

		print $mensaje;

		if ( $persistir eq 1 ) {

			$nombreArchivo = nombreArchivoDeSalida();
			open( FH, ">$nombreArchivo") || die "No se pudo crear el archivo de salida.\n";

			print FH "Consulta por mayor cantidad de hallazgos.\n" if ( $seleccion eq 1 );
			print FH "Consulta por cantidad de hallazgos nula.\n" if ( $seleccion eq 2 );

			print FH "\nExpresión lógica: ";

			foreach (@operandos) {

				$_ = "sistemas" if ( $_ eq "s" );
				$_ = "nombres de archivos" if ( $_ eq "a" );
				$_ = "patrones" if ( $_ eq "p" );
			}

			$expresion = $operandos[0];

			if ( ( $tipoExpresion eq 2 ) or ( $tipoExpresion eq 4 ) ){

				$expresion = $expresion." ".$flogica[0]." ".$operandos[1];
			}

			if ( $tipoExpresion eq 4 ) {
			
				$expresion = "( ".$expresion." ) ".$flogica[1]." ".$operandos[2];
			}

			if ( $tipoExpresion eq 3 ) {

				$expresion = $expresion." ".$flogica[0]." ";
				$expresion = $expresion."( ".$operandos[1]." ".$flogica[1]." ".$operandos[2]." )";
			}

			print FH $expresion."\n\n";

			print FH "Filtros:\n";

			if ( $#patrones >= 0 ) {
				print FH "Patrones: ";
				print FH "$_ " foreach (@patrones);
				print FH "\n";
			}

			if ( $#sistemas >= 0 ) {
				print FH "Sistemas: ";
				print FH "$_ " foreach (@sistemas);
				print FH "\n";
			}

			if ( $#archivos >= 0 ) {
				print FH "Nombres de archivo: ";
				print FH "$_ " foreach (@archivos);
				print FH "\n";
			}

			print FH "\nResultado:\n";
			print FH $mensaje;
			close FH;
		}

	} else {

		print "No se encontró el directorio de la variable de ambiente PROCDIR: $dir\n";
	}

}

# -----------------------------------------------------------------------------#
sub evaluarArchivo {

	my $dir     = shift(@_);	
	my $archivo = shift(@_);
	my $hash    = shift(@_);

	open( fileHandler, $dir."/".$archivo );

	$cantFunciones = @flogicas;

	my $evaluar_patrones = ( $#patrones >= 0 ) ? 1:0;
	my $evaluar_sistemas = ( $#sistemas >= 0 ) ? 1:0;
	my $evaluar_archivos = ( $#archivos >= 0 ) ? 1:0;

	if ($evaluar_patrones eq 1) {

		$patrones{$_} = 1 foreach (@patrones);
	}

	if ($evaluar_sistemas eq 1) {

		$sistemas{$_} = 1 foreach (@sistemas);
	}

	if ($evaluar_archivos eq 1) {

		$archivos{$_} = 1 foreach (@archivos);
	}

	$patron = $archivo;
	$patron =~ s/^[^.]+.(.*)$/\1/;

	while ( ( chop ($linea = <fileHandler>) ) and ( length($linea) > 0 ) ){

		@campos = split( $SEPARADOR_GLOBALES, $linea );

		# verifico si el registro cumple con los filtros ingresados.

		if ( $evaluar_patrones eq 1 ) { 

			$evaluacionDeOperandos{"p"} = (exists($patrones{ $patron })) ? 1:0;
		}

		if ( $evaluar_archivos eq 1 ) {

			$evaluacionDeOperandos{"a"} = (exists($archivos{ $campos[1] })) ? 1:0;
		}

		if ( $evaluar_sistemas eq 1 ) {

			my $sistema = $campos[1];

			$evaluacionDeOperandos{"s"} = 0;
			if ( $sistema =~ s/^([^_]*)_([^_]*)$/\1/ ) {

				$evaluacionDeOperandos{"s"} = (exists($sistemas{ $sistema })) ? 1:0;
			}
		}

		# verifico si el registro cumple con la expresión lógica.
		if ( &validarExpresionLogica( $tipoExpresion, \%evaluacionDeOperandos, \@operandos, \@flogicas) eq 1 ) {

			$hash->{$patron."|".$campos[1]} += $campos[2] ;
		}
	}
	close( fileHandler );
}

# -----------------------------------------------------------------------------#
sub validarExpresionLogica {

	my $tipoExpresion	   = shift(@_);
	my $evaluacionDeOperandos  = shift(@_);
	my $operandos		   = shift(@_);
	my $flogicas		   = shift(@_);

	$resultado = 0;

	$i = 0;
	push ( @orden, $i++ ) while ( $i < 3);

	if ( $tipoExpresion eq 3 ) {

		shift (@orden);
		push  (@orden, 0);
	}

	if ( $tipoExpresion eq 1 ) {

		$resultado = $evaluacionDeOperandos->{$operandos->[ $orden[0] ]};
	}

	else {
	
		$aux0 = $evaluacionDeOperandos->{$operandos->[$orden[0]]};
		$aux1 = $evaluacionDeOperandos->{$operandos->[$orden[1]]};

		$resultado = ( $aux0 and $aux1 ) if ( $flogicas->[0] eq "y" ) ;
		$resultado = ( $aux0 or  $aux1 ) if ( $flogicas->[0] eq "o" ) ;

		# si tengo dos funciones logicas
		if ( ($#flogicas +1 ) eq 2 ) {

			$aux2 = $evaluacionDeOperandos->{$operandos->[$orden[2]]};

			$resultado = ( $resultado and $aux2 ) if ( $flogicas->[1] eq "y" ) ;
			$resultado = ( $resultado or  $aux2 ) if ( $flogicas->[1] eq "o" ) ;
		}
	}

	return ($resultado);
}
