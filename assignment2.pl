:- dynamic dest/1.
:- dynamic departure/1.
:- dynamic gn/1.
:- dynamic hn/1.
:- style_check(-singleton).


getroute:-
retractall(gn(_,_,_)),retractall(hn(_,_,_)),retractall(departure(_)),retractall(dest(_)),
createKB,
getsource(S),
getdest(T),
dfs(S,T),bfs(S,T).

getdest(T):-
write('Goal City:   '),read(T),nl,
(gn(_,T,_),assert(dest(T)))
; 
write("Destination does not exist in database"),fail,nl.


getsource(S):-
write('Start City:  '),read(S),nl,
(gn(S,_,_),assert(departure(S))); 
write("Source does not exist in database"),fail,nl.


retracts:-
retractall(gn(_,_,_)),retractall(hn(_,_,_)),retractall(departure(_)),retractall(dest(_)).

createKB:-
csv_read_file('gn.csv',Gn,[functor(gn)]),maplist(assert,Gn),
csv_read_file('hn.csv',Hn, [functor(hn)]),maplist(assert,Hn).

dfs(S,T):-
Start = S,
End = T,
uninformed_search(Start,End,[Start],[],0).

uninformed_search(_,_,[],_,_):-
departure(A),dest(B),
write("no routes found from "),
write(A),write(" to "),
write(B),
write(" using Depth First Search").

uninformed_search(Start,End,_,Visited,Gn):-
dest(Start),reverse(Visited,P),
departure(A),dest(B),nl,nl,
write("USING DEPTH FIRST SEARCH"),nl,
write("Route distance: "),write(A),write(' to '),write(B),
write(' with DFS: '),write(Gn),nl,
write("** THE ROUTE IS **"),nl,
display_route(P,End).

uninformed_search(Start,End,Q,Visited,Gn):-
[_|T] = Q, gn(Start,New,Cost),
\+ member(New,Visited), GN is Gn+Cost, New \== Start,
uninformed_search(New,End,[New|T],[Start|Visited],GN).

display_route([H|T],E):-
write(H),write(' -> '),display_route(T,E).
display_route([],E):-
write(E).

bfs(S,T):-
hn(S,T,H_n),   
H = H_n, Start = S, End = T,
heuristic_search(0,Start,End,[H-Start],[]).


heuristic_search(_,_,_,[],_):-
departure(A),dest(B),
write("no routes found from "),
write(A),write(" to "),
write(B),
write(" using Best First Search").

heuristic_search(Gn,Start,End,_,Visited):-
dest(Start),
reverse(Visited,P),
departure(A),
dest(B),nl,nl,
write("USING BEST FIRST SEARCH"),nl,
write("Route distance: "),write(A),write(' to '),write(B),
write(' with Best First Search is: '),write(Gn),nl,
write("** THE ROUTE IS **"),nl,
display_route(P,End).


heuristic_search(Gn,Start,End,O,Visited):-
O=[Hd|T],
_-Curr = Hd,
E=End,
findall( Hr-N,
(
    Curr \==N,
    gn(Curr,N,_),
    \+member(N,Visited),
    hn(N,E,Hr)
),
List),
Follow = List,
append(Follow,T,O_n),
keysort(O_n,O_s),
[Next|_] = O_s,
_-NextCity = Next,
gn(Start,NextCity,Cost), 
UpdatedCost = Gn + Cost,
UpdatedVisited = [Start|Visited],
heuristic_search(UpdatedCost,NextCity,End,O_s,UpdatedVisited).
