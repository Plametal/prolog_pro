write_list([]).

write_list([Head|Tail]) :-
    write(Head), nl,
    write_list(Tail).
