pertenece_a(X, [X|_]):-!.
pertenece_a(X, [_|Z]):-
    pertenece_a(X,Z).

agrega_inicio(DATA,LIST,[DATA|LIST]).

combina([],List, List):-!.
combina([X|Lista1],Lista2,[X|Lista3]):-
    combina(Lista1, Lista2, Lista3).

count([],0).
count([_|Z], SUM):-
    count(Z, ACUM),
    SUM is ACUM + 1.

cuantas_aparece(_, [], 0):-!.
cuantas_aparece(DATA, [DATA|Z], SUM):-
    cuantas_aparece(DATA, Z, ACUM),
    SUM is ACUM + 1, !.
cuantas_aparece(DATA, [_|Z], SUM):-
    cuantas_aparece(DATA, Z, SUM).

invierte_lista([],Z,Z).
invierte_lista([X|Y],Z,ACUM):-
    invierte_lista(Y,Z,[X|ACUM]).

suma_lista([],0).
suma_lista([X|Z], SUM):-
    suma_lista(Z, ACUM),
    SUM is X + ACUM.

list_sum([],0):-!.
list_sum([Item], Item):-!.
list_sum([Item1,Item2 | Tail], Total) :-
    SUM is Item1 + Item2,
    list_sum([SUM|Tail], Total).

%Listas del mismo tama�o
suma_listas([],[],[]).
suma_listas([X|T],[Y|R],[SUM|L]):-
    SUM is X + Y,
    suma_listas(T,R,L).
