%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

:-op( 900,xfy,'::' ).
:-dynamic ponto_recolha/4, arco/3.
% :- include("pontos_recolha.pl").
% :- include("arcos.pl").

%---------------------------------------------------------------------
%         AUXILIARES BASE
%---------------------------------------------------------------------
% Termo, Predicado, Lista -> {V,F}
solucoes(T,Q,S) :- findall(T,Q,S).
%--------------------------------- - - - - - - - - - - - - - - -- - - 
% Predicado nao
nao(Questao) :-
    Questao,!,fail.
nao(_).
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado comprimento
comprimento(S,N) :-
    length(S,N).
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que da print
escrever([]).
escrever([X|T]) :-
    write(X),
    nl ,
    escrever(T).
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que adiciona a uma lista
add(X, [], [X]).
add(X, [Y | T], [X,Y | T]) :- X @< Y, !.
add(X, [Y | T1], [Y | T2]) :- add(X, T1, T2).

%---------------------------------------------------------------------
%    Tipos de Contentores
%---------------------------------------------------------------------

ponto_recolha(S) :- solucoes((Pid,NomeRua,Freguesia,C),ponto_recolha(Pid,NomeRua,Freguesia,C),S).
arco(S):- solucoes((IdO,IdD,Distancia),arco(IdO,IdD,Distancia),S).

%---------------------------------------------------------------------
%    MAKING MERDA
%---------------------------------------------------------------------
 ponto_recolha(1,"Tv Corpo Santo","Misericórdia",[("Lixos",10,8),("Papel",10,2)]).
 ponto_recolha(2,"R Corpo Santo","Misericórdia",[("Lixos",10,7)]).
 ponto_recolha(3,"R Bernardino da Costa","Misericórdia",[("Papel",10,1),("Lixos",10,7)]).
 ponto_recolha(4,"Lg Corpo Santo","Misericórdia",[("Papel",10,1),("Lixos",10,7)]).
 ponto_recolha(5,"Pc Duque da Terceira","Misericórdia",[("Papel",10,1),("Lixos",10,7)]).
 
 arco(1,2,20).
 arco(1,3,10).
 arco(1,4,50).
 arco(2,4,10).
 arco(3,4,10).
 arco(4,5,30).
%---------------------------------------------------------------------
%    Não Informada
%---------------------------------------------------------------------

%-------------------------DEPTH FIRST-------------------------
% Trajeto entre dois pontos
trajeto(Origem,Destino, [Origem|Caminho], Distancia) :-                           
    trajetoAux(Origem, Destino,Caminho, Distancia,[]).                             

trajetoAux(Destino,Destino, [], 0, _).                                              
trajetoAux(Origem,Destino ,[Prox|Caminho], Distancia, Visitados) :-
    Origem \== Destino,                                                               
    adjacente(Origem, Prox, Dist1),                                        
    nao(member(Prox,Visitados)),                                                       
    trajetoAux(Prox, Destino, Caminho, Dist2,[Origem|Visitados]),
    Distancia is Dist1 + Dist2.                                           

adjacente(Origem, Prox, Distancia) :-                                              
    arco(Origem,Prox, Distancia).                                                  

todos(Origem,Destino,L):-
    findall((S,Distancia),trajeto(Origem,Destino,S,Distancia),L),                         
    escrever(L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
 % Trajeto entre dois pontos, com pontos de paragem de determinado lixo
lixo(Origem, Dest , [Origem|Caminho], [Tipo_Lixo],Distancia) :-
    lixoProx(Origem, Dest, Caminho, [Tipo_Lixo], Distancia, []).

lixoProx(Dest, Dest, [], _ , 0 , _).
lixoProx(Origem, Dest, [Prox|Caminho], Tipo_Lixo, Distancia, Visitados) :-
    Origem \== Dest,                                                                     
    getPonto(Origem,Prox,Tipo_Lixo1,Dist1),                                     
    nao(member(Prox,Visitados)),                                                         
    member(Tipo_Lixo1,Tipo_Lixo),                                                        
    lixoProx(Prox, Dest, Caminho, Tipo_Lixo , Dist2,[Origem | Visitados]),
    Distancia is Dist1 + Dist2.                                                

getPonto(Origem,Prox,Tipo_Lixo,Distancia):-
    arco(Origem,Prox,Distancia),                                                       
    ponto_recolha(Prox,_,_,Lista_Lixos),
    member((Tipo_Lixo,_,_),Lista_Lixos).        

todosLixo(Origem,Destino,[Tipo_Lixo]):-
    findall((S,Distancia),lixo(Origem,Destino,S,[Tipo_Lixo],Distancia),L),
    escrever(L).% print listas

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Identificar quais os circuitos com mais pontos de recolha (por tipo de resíduo a recolher)
tamanho([],[]).
tamanho([(H,E)],[((X,H),E)]) :-
    comprimento(H,X).
tamanho([(H,E)|T],[((X,H),E)|S]) :-
    comprimento(H,X),
    tamanho(T,S).


maior([((P,_),_)],P).
maior([((Px,_),_)|L],Px):- maior(L,Py), Py =< Px.
maior([((Px,_),_)|L],Py):- maior(L,Py), Px < Py.

% FILTRA POR NUMERO DE PONTOS D RECOLHA 
filterP([],_,[]).
filterP([((NP,_),_)|T],MAX,R) :-
    MAX \== NP ,
    filterP(T,MAX,R).
filterP([((NP,P),D)|T],MAX,K) :-
    MAX == NP,
    filterP(T,MAX,R),
    append([(P,D)],R,K).

maisPontos(Origem,Destino):-
    findall((S,Distancia),trajeto(Origem,Destino,S,Distancia),L),
    tamanho(L,X),
    maior(X,M),
    filterP(X,M,R),
    escrever(R).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Comparar circuitos de recolha tendo em conta os indicadores de produtividade:
% A quantidade recolhida: quantidade de resíduos recolhidos durante o circuito;
% A distância media percorrida entre pontos de recolha.
compCircuito(Origem,Destino, [Origem|Caminho], Distancia,QLixo) :-                           
    compCircuitoAux(Origem, Destino,Caminho, Distancia,[],[]).   

somaLixo([],[]).
somaLixo([(T,Cap,Quant)|L],[(T,C2)|K]):-
C2 is Cap*Quant,
somaLixo(L,K).

compCircuitoAux(Dest, Dest, [], _ , 0 , _,[]) .
compCircuitoAux(Origem, Dest, [Prox|Caminho], Distancia, Visitados,[K|QLixo]) :-
    Origem \== Dest,                                                                     
    adjacente(Origem,Prox,Dist1),                                     
    nao(member(Prox,Visitados)),
    ponto_recolha(Origem,_,_,L),   
    somaLixo(L,K),
    compCircuitoAux(Prox, Dest, Caminho, Dist2,[Origem | Visitados],QLixo),
    Distancia is Dist1 + Dist2.

todosComp(Origem,Destino):-
    findall((S,Distancia,QLixo),compCircuito(Origem,Destino,S,Distancia,QLixo),L),
    escrever(L).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Escolher o circuito mais rápido (usando o critério da distância)
minimo6([(_,Y)],Y) :-
    !,
    true.
minimo6([(_,Y)|Xs], M):-
    minimo6(Xs, M),
    M =< Y.
minimo6([(_,Y)|Xs], Y):-
    minimo6(Xs, M),
    Y <  M.

%FILTRA POR DISTANCIA MINIMA
filter6([],_,[]).
filter6([(_,D)|T],Min,R) :-
    Min \== D ,
    filter6(T,Min,R).
filter6([(X,D)|T],Min,K) :-
    Min == D,
    filter6(T,Min,R),
    append([(X,D)],R,K).


maisRapido(Origem,Destino):-
    findall((S,Distancia),trajeto(Origem,Destino,S,Distancia),L),
    minimo6(L,Dist),
    filter6(L,Dist,R),
    escrever(R).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Escolher o circuito mais eficiente (usando um critério de eficiência à escolha) - menos distância , mais lixo




%maisEficiente(Origem,Destino):-
%    findall((S,Distancia),trajeto(Origem,Destino,S,Distancia),L).
    
    %minimo6(L,Dist),
    %filter6(L,Dist,R),

%ponto_recolha(1,"Tv Corpo Santo","Misericórdia",[("Lixos",10,8),("Papel",10,2)]).

%total_lixo is total_lixo+

%----------------------------------------------------------------%
%                         INFORMADA                              %
%----------------------------------------------------------------%

%-----------------------------A Estrela----------------------------------

resolve_aestrela(Origem, Destino, Caminho/Custo) :- 
    arco(Origem,Destino,Distancia),                                   
    aestrela([[(Origem, Destino)]/0/Distancia], Caminho/Custo/_).
    %inverso(InvCaminho, Caminho).

aestrela(Caminhos, Caminho) :-
    obtem_melhor(Caminhos, Caminho),
    Caminho = [(Nodo, Destino)|_]/_/_,
    Nodo == Destino.
aestrela(Caminhos, SolucaoCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho),
    seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
    expande_aestrela(MelhorCaminho, ExpCaminhos),
    append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
        aestrela(NovoCaminhos, SolucaoCaminho).

obtem_melhor([Caminho], Caminho) :- !.
obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Custo1 + Est1 =< Custo2 + Est2, !,
    obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
obtem_melhor([_|Caminhos], MelhorCaminho) :-
    obtem_melhor(Caminhos, MelhorCaminho).

expande_aestrela(Caminho, ExpCaminhos) :-
    findall(NovoCaminho, adjacente(Caminho,NovoCaminho), ExpCaminhos).


adjacente([(Nodo,Destino)|Caminho]/Custo/_, [(ProxNodo,Destino),(Nodo,Destino)|Caminho]/NovoCusto/Est) :-
    arco(Nodo, ProxNodo, PassoCusto,_),
    \+ member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    distancia(ProxNodo, Destino, Est).

seleciona(E, [E|Xs], Xs).
seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).


% Aplica o inverso a uma lista
inverso(Xs, Ys):-
	inverso(Xs, [], Ys).
inverso([], Xs, Xs).
inverso([X|Xs],Ys, Zs):-
	inverso(Xs, [X|Ys], Zs).


 
same([X],R) :- append([X],[],R).
same([(Tipo, Q),(Tipo,Q2)|T], R) :- 
    Q3 is Q + Q2,
    same([(Tipo,Q3)|T], R), !.
same([(Tipo, Q1),(Tipo2,Q2)|T], R) :- 
    same([(Tipo,Q1)|T], R1),
    same([(Tipo2,Q2)|T], R2),
    append(R1,R2,R).


% remdup(List, List_No_duplicates).
remdup([],[]).
remdup([X|T],Lnd):- rd1(X,T,T1,X1), remdup(T1,Tnd),Lnd=[X1|Tnd].

% rd1(X,L,Lr) removes all occurance of X in List L and store result in List Lr
rd1(X,[],[],X).    
rd1((Tipo,Q1),[(Tipo,Q2)|T],Lx,X1):- 
    ( Q1>=Q2 
    -> X1 = (Tipo,Q1)
    ;  X1 = (Tipo,Q2)
    ), 
    rd1(X1,T,Lx, X1), !.
rd1(X,[Y|T],Lx,X1):-  rd1(X,T,Lx1,X1), Lx=[Y|Lx1], !.