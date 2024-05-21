parent(albert, bob).
parent(albert, betsy).
parent(albert, bill).

parent(alice, bob).
parent(alice, betsy).
parent(alice, bill).

parent(bob, carl).
parent(bob, charlie).

get_grandchild :-
    parent(albert, X),
    parent(X, Y),
    write('Alberts grandchild is '),
    write(Y), nl.

get_grandparent :-
    parent(X, carl),
    parent(X, charlie),
    format('~w ~s grandparent ~n~n~n', [X, "is the"]).

brother(bob, bill).

grand_parent(X, Y) :-
    parent(Z, X),
    parent(Y, Z).

blushes(X) :- human(X).
human(derek).

what_grade(5) :-
    write('Go to kindergarten').

what_grade(6) :-
    write('Go to 1st Grade').

what_grade(Other) :-
    Grade is Other - 5,
    format('Go to grade ~w', [Grade]).

print(X) :-
    format('~w is name.', [X]).
