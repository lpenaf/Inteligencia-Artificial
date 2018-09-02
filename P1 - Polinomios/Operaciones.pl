% Por el típo de implementación el grado
% es el número de elementos en la lista. 
grado([],0):-!.
grado([_],0):-!.
grado([_|Z], SUM):-
    grado(Z, ACUM),
    SUM is ACUM + 1.

% Hay una implementación de suma y resta más fácil y corta en
% https://stackoverflow.com/questions/26936560/multiply-two-polynomials-in-prolog
% también con ese sale la multipliación.
suma([],[],[]):-!.
suma(PolA, PolB, PolS):-
	 grado(PolA, X),
	 grado(PolB, Y),
	 (X =:= Y ->
	 	suma_lista(PolA, PolB, PolS);
	 	(X > Y ->
	 		G is X - Y,
	 		build_zeros(G,L),
	 		combina(PolB, L, New),
	 		suma_lista(PolA, New, PolS);
	 		G is Y - X,
	 		build_zeros(G,L),
	 		combina(PolA, L, New),
	 		suma_lista(New, PolB, PolS))).

resta([],[],[]):-!.
resta(PolA, PolB, PolS):-
	 grado(PolA, X),
	 grado(PolB, Y),
	 (X =:= Y ->
	 	resta_lista(PolA, PolB, PolS);
	 	(X > Y ->
	 		G is X - Y,
	 		build_zeros(G,L),
	 		combina(PolB, L, New),
	 		resta_lista(PolA, New, PolS);
	 		G is Y - X,
	 		build_zeros(G,L),
	 		combina(PolA, L, New),
	 		resta_lista(New, PolB, PolS))).

deriva([],[]):-!.
deriva([_],[0]):-!.
deriva(Coeffs, Deriv):-
	multiply_list(Coeffs,0,Res),
	quita_primero(Res, Deriv).

% Métodos auxiliares.
suma_lista([],[],[]).
suma_lista([X|T],[Y|R],[SUM|L]):-
    SUM is X + Y,
    suma_lista(T,R,L).

resta_lista([],[],[]).
resta_lista([X|T],[Y|R],[DIFF|L]):-
    DIFF is X - Y,
    resta_lista(T,R,L).

multiply_list([], _, []).
multiply_list([X|Y], Number, [X1|L]):-
     X1 is X * Number,
     Z is Number + 1,
     multiply_list(Y, Z, L).

quita_primero([],[]).
quita_primero([_|X],X).

build_zeros(0,[]):-!.  
build_zeros(N1,[0|L]) :-
  N1 > 0, N is N1 - 1,
  build_zeros(N,L).

combina([],List,List):-!.
combina([X|Lista1],Lista2,[X|Lista3]):-
    combina(Lista1, Lista2, Lista3).
