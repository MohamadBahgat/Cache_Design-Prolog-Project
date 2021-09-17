:- use_module(library(clpfd)).
cls :- write('\33\[2J').


												% ------------
												% General Part
												% ------------
												
												

% Replace an item in a list at a specific location.  shape --> replaceIthItem(Item,List,I,Result)
% _______________________________________________________________________________________________

replaceIthItem(E, [_|Xs], 0, [E|Xs]).
replaceIthItem(E, [X|Xs], N, [X|Ys]) :-
   N #> 0,
   N #= N0+1,
   replaceIthItem(E, Xs, N0, Ys).

/*   
	replaceIthItem([a,b,c,d],1,z,Ls).
	Ls = [a,z,c,d]
*/



% Convert from Binary to Decimal.  shape --> convertBinToDec(BinaryNum, EquivalentDecimal)
% ________________________________________________________________________________________
  
convertBinToDec(Bits, N) :-
	
	numToList(Bits, _, Result),
    binary_number_min(Result, 0, N, N).

binary_number_min([], N, N, _M).
binary_number_min([Bit|Bits], N0,N, M) :-
    Bit in 0..1,
    N1 #= N0*2 + Bit,
    M #>= N1,
    binary_number_min(Bits, N1,N, M).



% Log of Base_2  shape --> logBase2(Num,Res)
% __________________________________________

logBase2(I, E) :-
    (   number(I)
    ->  E is ceiling(log(I)/log(2))
    ;   number(E)
    ->  I is 2**E
	; ! ).
	
	
	
% Split Every  shape -->  splitEvery(N,List,Res)
% ______________________________________________

splitEvery( _, [], []) .
splitEvery( N, [X|Xs], [Pfx|Tail] ) :-
	first(N,[X|Xs],Pfx,Sfx),
	splitEvery(N,Sfx,Tail) .
	
first( N, [X|L], [X|Xs], Sfx ) :- N > 0 , N1 is N-1 , first( N1, L, Xs, Sfx ) .
first( N, [], [], []) :- N > 0 .
first( 0, Xs, [], Xs) .	



% Get Number of Bits of the cache    shape --> getNumBits(NumOfSets,Type,Cache,BitsNum)
% _____________________________________________________________________________________

getNumBits(_,fullyAssoc,_,0).

getNumBits(NumOfSets,setAssoc,Cache,BitsNum):-
	length(Cache, Len),
	RowsPerSets is ceiling(Len / NumOfSets),
	logBase2(RowsPerSets, BitsNum).


/* getNumBits(_,directMap,[item(tag(S),_,_,_)|_],BitsNum):-
	string_length(S,StrLength),
	logBase2(StrLength,IndexNum),
	BitsNum is StrLength - IndexNum. */
	
getNumBits(_,directMap,Cache,BitsNum):-
	length(Cache, Len),
	logBase2(Len, BitsNum).	
	
	
	
% Fill Zeros  shape --> fillZeros(String,N,R)
% ___________________________________________

fillZeros(String,N,String):-
	N = 0.

fillZeros(String,N,R):-
	N > 0,
	N2 is N -1,
	string_concat("0", String, R2),
	fillZeros(R2,N2,R).
	
	
	

							% ----------------------------------------------
							% Direct Maping Part And Fully Associative Part
							% ----------------------------------------------
							


% getDataFromCache  shape --> getDataFromCache(StringAddress,Cache,Data,HopsNum,directMap,BitsNum)
% ________________________________________________________________________________________________

getDataFromCache(StringAddress,Cache,Data,HopsNum,directMap,BitsNum):-
	string_chars(StringAddress,BinaryAddAsList),
	length(BinaryAddAsList, BinaryAddLength),
	SplitOnIndex is BinaryAddLength - BitsNum,
	split_at(SplitOnIndex, BinaryAddAsList, [TagAsList,IdxAsList|_]),
	string_chars(TagAsString,TagAsList),
	string_chars(IdxAsString,IdxAsList),
	number_string(IdxAsBinary,IdxAsString),
	convertBinToDec(IdxAsBinary, IdxAsDecimal),
	nth0(IdxAsDecimal, Cache, item(tag(BlockTagAsString),data(BlockData),Validity,_)),
	item(tag(TagAsString),_,1,_) = item(tag(BlockTagAsString),_,Validity,_),
	Data is BlockData,
	HopsNum is 0.
	

% getDataFromCache  shape --> getDataFromCache(StringAddress,Cache,Data,HopsNum,fullyAssoc,BitsNum)
% ________________________________________________________________________________________________

getDataFromCache(StringAddress,Cache,Data,HopsNum,fullyAssoc,_):-
	number_string(BinaryAddress,StringAddress),
	convertBinToDec(BinaryAddress, DecimalAddress),
	nth0(DecimalAddress, Cache, item(tag(BlockTagAsString),data(BlockData),Validity,_)),
	item(tag(StringAddress),_,1,_) = item(tag(BlockTagAsString),_,Validity,_),
	Data is BlockData,
	HopsNum is 1.
	


% convert Address   shape --> convertAddress(BinaryAdd,BitsNum,A,directMap)
% _________________________________________________________________________

convertAddress(BinaryAdd,BitsNum,Tag,Idx,directMap):-
	numToList(BinaryAdd, _, BinaryAddAsList),
	length(BinaryAddAsList, BinaryAddLength),
	SplitOnIndex is BinaryAddLength - BitsNum,
	split_at(SplitOnIndex, BinaryAddAsList, [First,Second|_]),
	numToList(Tag,_,First),
	numToList(Idx,_,Second).

% convert Address   shape --> convertAddress(BinaryAdd,BitsNum,A,fullyAssoc)
% _________________________________________________________________________

convertAddress(BinaryAdd,_,Tag,_,fullyAssoc):-
	convertBinToDec(BinaryAdd,Num),
	convertBinToDec(Tag,Num).	



% Helper Functions 
% ________________



numToList(Number, 0, [Number]) :- Number in 0..9.
numToList(Number, N, [Digit|Digits]) :-
        Digit in 0..9,
        N #= N1 + 1,
        Number #= Digit*10^N + Number1,
        Number1 #>= 0,
        N #> 0,
        numToList(Number1, N1, Digits).



split_at(N, List, [H|[T]]) :-
	append(H, T, List), length(H, N).
	
/* split_at(4, [1,2,3,4,5,6,7,8], X).
   X = [[1, 2, 3, 4], [5, 6, 7, 8]] ;
*/

removeNegativeSign(X,Y):-
	X < 0,
	Y is -X.
removeNegativeSign(X,Y):-
	Y is X.	
	

   