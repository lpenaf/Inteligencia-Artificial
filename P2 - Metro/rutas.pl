:- ensure_loaded(stcm). %Carga la base de conocimiento

estaciones_conectadas(X,Y,L) :- conexion(X,Y,L).
estaciones_conectadas(X,Y,L) :- conexion(Y,X,L).

estaciones_adyacentes(X, Z):-
       findall(Y, estaciones_conectadas(X, Y,_), Z).

camino(A,B,Path,Len) :-
       recorre(A,B,[A],Q),
       reverse(Q,Path),
       longitud_camino(Path,Len).

%esta es busqueda en profundidad
recorre(A,B,P,[B|P]) :-
       estaciones_conectadas(A,B,_).
recorre(A,B,Visited,Path) :-
       estaciones_conectadas(A,C,_),
       C \== B,
       \+member(C,Visited),
       recorre(C,B,[C|Visited],Path).

%longitud_camino(i,o).
%Calcula el n�mero de estaciones a recorrer
%de un camino dado, i.
%
%Notar que el camino dado a calcular
%debe ser un camino v�lido.
longitud_camino([_],0):-!.
longitud_camino([A,B|R],Len):-
       estaciones_conectadas(A,B,L),
       longitud_camino([B|R],T),
       Len is T + L.

%largo_camino(i,o).
%Calcula la longitud de un camino dado, i.
%Notar que el camino dado a calcular
%debe ser un camino v�lido.
largo_camino([_],0):-!.
largo_camino([A,B|R],Len):-
       estaciones_conectadas(A,B,_),
       largo_camino([B|R],T),
       Len is T + 1.

estacion_a_menor_distancia(EstacionInicio,EstacionResultado,Distancia):-
       estaciones_adyacentes(EstacionInicio, ListaAdyacentes),
       estacion_menor(EstacionInicio,ListaAdyacentes,EstacionResultado,Distancia).

% El siguiente predicado regresa la estaci�n adyacente, seg�n la lista
% de estaciones adyacentes que recibe,que est� a la menor distancia de
% la estacion dada.
%
% i: Estacion de la que se quiere obtener la estaci�n a menor distancia
% i: Lista de las estaciones adyacentes
% o: Nombre de la estacion con distancia menor adyacente
% o: Distancia a la estacion adyacente
estacion_menor(Inicio,[],Inicio,0):-!.
estacion_menor(Inicio,[A],A, Dist):-
       estaciones_conectadas(Inicio,A,Dist),!.
estacion_menor(Inicio,[Primera|Cola],Estacion,Res):-
       estacion_menor_aux(Inicio,Primera,Cola,Estacion,Res),!.

estacion_menor_aux(EstacionInicial,EstacionMenorActual,[],EstacionMenorActual,Distancia):-
            estaciones_conectadas(EstacionInicial,EstacionMenorActual,Distancia),!.
estacion_menor_aux(EstacionInicial,EstacionMenorActual,[EstacionAPrueba|Resto],Estacion,Res):-
       estaciones_conectadas(EstacionInicial,EstacionMenorActual,J),
       DistanciaActual is J,
       estaciones_conectadas(EstacionInicial, EstacionAPrueba,K),
       DistanciaAComparar is K,
        (   DistanciaActual > DistanciaAComparar ->
        estacion_menor_aux(EstacionInicial,EstacionAPrueba,Resto,Estacion,Res);(
       estacion_menor_aux(EstacionInicial,EstacionMenorActual,Resto,Estacion,Res)
                                )).

%Rutas es una lista de listas
transforma_rutas_a_distancia(Rutas,Distancias):-
       trans_aux(Rutas,[],Distancias).
trans_aux([],ListaTemp,ListaTemp).
trans_aux([RutaActual|Resto],ListaTemp,Final):-
       longitud_camino(RutaActual,DistanciaActual),
       append(ListaTemp,[DistanciaActual],Res),
       trans_aux(Resto,Res,Final).

%agrega_rutas_a_cola_de_prioridad([],Cola,Cola):-!.
agrega_rutas_a_cola_de_prioridad(Destino,Ruta,Cola,Resultado):-
       append([Ruta],Cola,ColaParcial),
       ordena(Destino,ColaParcial,Resultado).

%insertion sort
ordena(_,[],[]).
ordena(Destino,[Cabeza|Cola],Resultado):-
       ordena(Destino,Cola,ResP),
       agrega_orden(Destino,Cabeza,ResP,Resultado).

%aqui agrega comparando las distancias de las rutas
agrega_orden(_,Elem,[],[Elem]):-!.
agrega_orden(Destino,Elem,[X|Y],[Elem,X|Y]):-
       heuristica(Destino,Elem,Res1),
       heuristica(Destino,X,Res2),
       Res1 =< Res2,!.
agrega_orden(Destino,Elem,[X|Y],[X|Z]):-
       agrega_orden(Destino,Elem,Y,Z),!.

%este metodo calcula la heuristica de la situacion actual
% i: nodo destino
% i: lista del camino
% o: valor calculado
heuristica(Destino, [EstacionActual|CaminoRecorrido], ValorCalculado):-
       longitud_camino([EstacionActual|CaminoRecorrido],Res1),
       heuristica_geografica(EstacionActual,Destino,Res2),
       ValorCalculado is Res1 + Res2.

heuristica_geografica(EstacionOrigen,EstacionDestino,Resultado):-
       estacion(EstacionOrigen,Coord1,Coord12),
       estacion(EstacionDestino,Coord2,Coord22),
       calcula_distancia(Coord1,Coord12,Coord2,Coord22,Resultado).

calcula_distancia(Ll1,Ln1,Ll2,Ln2,Res):-
       Res is sqrt( (Ll1-Ll2)**2 + (Ln1-Ln2)**2) * 110.57. %110.57,111.70

ruta_Aestrella(Origen,Destino,Ruta):-
       estacion(Origen,_,_),
       estacion(Destino,_,_),
       recorre_Aestrella(Destino,[Origen],[],Ruta).

%Destino,Ruta actual, cola de prioridad,Resultado
recorre_Aestrella(Destino,[Destino|Resto],_,[Destino|Resto]):-!.

% aqui lo que tiene que hacer es llamar a todos los adyacentes,
% concatenarlos a la ruta actual
%agregarlos a la cola de prioridad y seguir recorriendo
recorre_Aestrella(Destino,[CabezaRutaActual|ColaRutaActual],ColaDePrioridad,Resultado):-
       %de los resultados de ruta actual con sus adyacentes       write("Bandera 1"),nl,
       estaciones_adyacentes(CabezaRutaActual,ResultadosAdyacentes),
       %write("Adyacentes a "),write(CabezaRutaActual),write(" son : "),nl,write("    "),write(ResultadosAdyacentes),
       %agregar todos a cola de prioridad, meter si no estan repetidos o si la ruta no esta repetida
       inserta_aux(Destino,[CabezaRutaActual|ColaRutaActual],ResultadosAdyacentes,ColaDePrioridad,[CabezaColaActualizada|RestoColaActualizada]),
       %nos regresa la cola de prioridad y el ultimo argumento es una lista de listas
       %nl,nl,write("Despu�s de agregar adyacentes. "),write([CabezaColaActualizada|RestoColaActualizada]),nl,nl,
       %write(" * * *  RECURSION ESTRELLA * * *"),nl,
       %write([CabezaColaActualizada|RestoColaActualizada]),nl,nl,
       recorre_Aestrella(Destino,CabezaColaActualizada,RestoColaActualizada,Resultado).

%Destino,RutaActual,ListaAdyacentes,ColaDePrioridad,Res)
inserta_aux(_,_,[],ColaDePrioridadActualizada,ColaDePrioridadActualizada):-!.
inserta_aux(Destino,[CabezaRutaActual|RestoRutaActual],[CabezaListaAdyacentes],ColaPrioridad,Resultado):-
      (   \+member(CabezaListaAdyacentes,[CabezaRutaActual|RestoRutaActual]) ->
      append([CabezaListaAdyacentes],[CabezaRutaActual|RestoRutaActual],AInsertar),
      %Destino,Ruta,Cola,Resultado
      agrega_rutas_a_cola_de_prioridad(Destino,AInsertar,ColaPrioridad,ResP),
          inserta_aux(_,_,[],ResP,Resultado)
      ;inserta_aux(_,_,[],ColaPrioridad,Resultado)),!.

inserta_aux(Destino,RutaActual,[CabezaListaAdyacentes|RestoListaAdyacentes],ColaPrioridad,Resultado):-
       %nl,nl,nl,write(ColaPrioridad),nl,nl,nl,
       %nl,nl,write("Inserta a adyacentes"),
       (\+member(CabezaListaAdyacentes,RutaActual)->
       append([CabezaListaAdyacentes],RutaActual,AInsertar),
       %write("antes de agregar a la cola :     "),nl,nl,write(ColaPrioridad),
       agrega_rutas_a_cola_de_prioridad(Destino,AInsertar,ColaPrioridad,ColaPrioridadActualizada),
       %write("despues de agregar a la cola :     "),nl,nl,write(ColaPrioridadActualizada),

       % nl,nl,write("Se va a insertar : "),nl,nl,write(AInsertar),
        %DETALLE
        %nl,write("-> Cola de prioridad actual"),write([Cabeza|ColaPrioridadActualizada]),nl,
        inserta_aux(Destino,RutaActual,RestoListaAdyacentes,ColaPrioridadActualizada,Resultado);
       %en caso de que este en la lista
       %write("Ya estaba en lista de prioridad"),
        inserta_aux(Destino,RutaActual,RestoListaAdyacentes,ColaPrioridad,Resultado)
       ).

imprime([]):-!.
imprime([Ultimo]):-
       write(Ultimo).
imprime([Cabeza|Resto]):-
       write(Cabeza),
       nl,
       imprime(Resto).

calcula_ruta_optima(Origen,Destino,RutaDesdeInicio):-
       ruta_Aestrella(Origen,Destino,RutaI),!,
       reverse(RutaI,RutaDesdeInicio),
       longitud_camino(RutaDesdeInicio,Len),
       largo_camino(RutaDesdeInicio,Size),
       write("Distancia: "), write(Len),nl,
       write("# estaciones: "), write(Size),nl,
       %write(RutaDesdeInicio),!.
       imprime(RutaDesdeInicio),!.

caminos(A, B):-
	camino(A, B, X, _),
	write(X),
	nl,
	fail.

escribe_caminos(A, B) :-
    open('file.txt', write, Stream),
    ( camino(A, B, X, L), write(Stream, X), write(Stream," "), write(Stream, L), nl(Stream), fail; true ),
    close(Stream).