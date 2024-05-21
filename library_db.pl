% library_db.pl
:- module(library_db, [book/4, title_search/1, classification_genre/1,
                      loan_status/2, book_list/0, loan_status_list/0,
                      borrower_list/0, borrower/3, book_status/1,
                      book_loan/0, checkout_book/3, return_book/1]).


%1 book database (Barcode, Title, Author, Genre)
book(1001, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction').
book(1002, '1984', 'George Orwell', 'Dystopian').
book(1003, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction').
book(1004, 'A Brief History of Time', 'Stephen Hawking', 'Science').
book(1005, 'Pride and Prejudice', 'Jane Austen', 'Romance').
book(1006, 'The Catcher in the Rye', 'J.D. Salinger', 'Fiction').
book(1007, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy').
book(1008, 'The Da Vinci Code', 'Dan Brown', 'Thriller').
book(1009, 'Moby-Dick', 'Herman Melville', 'Adventure').
book(1010, 'Brave New World', 'Aldous Huxley', 'Dystopian').

%5 title search
title_search(Title) :-
    book(Barcode, Title, _, _),
    book_status(Barcode).


%4 genre search
classification_genre(Genre) :-
    write('Barcode\tTitle\tAuthor'), nl,
    book(Barcode, Title, Author, Genre),
    format('~w\t~w\t~w', [Barcode, Title, Author]), nl.

%2 book status check
:- dynamic loan_status/2.
loan_status(1001, available).
loan_status(1002, available).
loan_status(1003, available).
loan_status(1004, available).
loan_status(1005, available).
loan_status(1006, available).
loan_status(1007, available).
loan_status(1008, available).
loan_status(1009, available).
loan_status(1010, available).

%3 make data list
% book
book_list :-
    book(Barcode, Title, Author, Genre),
    format('~w \t ~w \t ~w \t ~w', [Barcode, Title, Author, Genre]), nl.
% loan_status
loan_status_list :-
    loan_status(Barcode, Status),
    format('~w \t ~w', [Barcode, Status]), nl.
% borrower
borrower_list :-
    borrower(Name, Phone_number, Barcode),
    format('~w \t ~w \t ~w', [Name, Phone_Number, Barcode]), nl.

%9 borrower db
:- dynamic borrower/3.



%6 book loan check
book_status(Barcode) :-
    loan_status(Barcode, Status),
    book(Barcode, Title, _, _),
    format('Barcode: ~w, Title: ~w, Status: ~w', [Barcode, Title, Status]).


%7 book loan
book_loan :-
    write('Enter your name : '),
    read(Name),
    write('Enter your phone number : '),
    read(Phone_number),
    write('Enter the book barcode'),
    read(Barcode),
    checkout_book(Name, Phone_number, Barcode).

% checkout book
checkout_book(Name, Phone_number, Barcode) :-
    loan_status(Barcode, available),
    retract(loan_status(Barcode, available)),
    assertz(loan_status(Barcode, checked_out)),
    assertz(borrower(Name, Phone_number, Barcode)),
    write('Book checked out successfully.'), nl.

checkout_book(Name, Phone_number, Barcode) :-
    loan_status(Barcode, checked_out),
    write('Book is already checked out.'), nl.


%8 return book
return_book(Barcode) :-
    loan_status(Barcode, checked_out),
    retract(loan_status(Barcode, checked_out)),
    assertz(loan_status(Barcode, available)),
    retract(borrower(Name, Phone_number, Barcode)).
