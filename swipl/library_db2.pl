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

%2 loan_status_db (Barcode, Status)
:- dynamic loan_status/2.
loan_status(1001, checked_out).
loan_status(1002, available).
loan_status(1003, available).
loan_status(1004, available).
loan_status(1005, available).
loan_status(1006, available).
loan_status(1007, available).
loan_status(1008, available).
loan_status(1009, available).
loan_status(1010, available).

%3 borrower db (Name, Phone_number, Barcode)
:- dynamic borrower/3.
borrower('Tom', '010-1234-5678', 1001).

%4 make data list
% making_book_infomation_list
book_list :-
    book(Barcode, _, _, _),
    book_status(Barcode).
% making_loan_status_list
loan_status_list :-
    loan_status(Barcode, Status),
    format('~w \t ~w', [Barcode, Status]), nl.
% making_borrower_list
borrower_list :-
    borrower(Name, Phone_number, Barcode),
    format('~w \t ~w \t ~w', [Name, Phone_number, Barcode]), nl.


%5 title search
title_search(Part) :-
    book(Barcode, Title, _, _),
    sub_string(Title, _, _, _, Part),
    book_status(Barcode).


%6 genre search
classification_genre(Genre) :-
    book(Barcode, _, _, Genre),
    book_status(Barcode).



%7 book_status (Barcode, Title, Author, Genre, Status)
book_status(Barcode) :-
    loan_status(Barcode, Status),
    book(Barcode, Title, Author, Genre),
    format('Barcode: ~w, Title: ~w, Author: ~w, Genre: ~w, Status: ~w', [Barcode, Title, Author, Genre, Status]), nl.


%8 book loan
book_loan :-
    write('Enter your name : '),
    read(Name),
    write('Enter your phone number : '),
    read(Phone_number),
    write('Enter the book barcode'),
    read(Barcode),
    checkout_book(Name, Phone_number, Barcode).

%9 checkout book-1
checkout_book(Name, Phone_number, Barcode) :-
    loan_status(Barcode, available),
    retract(loan_status(Barcode, available)),
    assertz(loan_status(Barcode, checked_out)),
    assertz(borrower(Name, Phone_number, Barcode)),
    write('Book checked out successfully.'), nl.
% -2
checkout_book(Name, Phone_number, Barcode) :-
    loan_status(Barcode, checked_out),
    write('Book is already checked out.'), nl.


%10 return book
return_book(Barcode) :-
    loan_status(Barcode, checked_out),
    retract(loan_status(Barcode, checked_out)),
    assertz(loan_status(Barcode, available)),
    retract(borrower(Name, Phone_number, Barcode)).
