:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).

%
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

%
:- http_handler(root(.), home_page, []).
:- http_handler(root(book), book_page, []).

%
home_page(_Request) :-
    reply_html_page(
        title('Library Home'),
        [ h1('Welcome to the Library'),
          p('Go to the list of books:'),
          a(href('/book'), 'Books')
        ]).

%
book_page(_Request) :-
    findall(Title, book(_, Title, _, _), Titles),
    reply_html_page(
        title('Books'),
        [ h1('Books Available'),
          \book_list(Titles)
        ]).

%
book_list([]) -->
    [].
book_list([H|T]) -->
    html([ li(H) ]),
    book_list(T).

%   ( )
book(1001, 'The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction').
book(1002, '1984', 'George Orwell', 'Dystopian').
book(1003, 'To Kill a Mockingbird', 'Harper Lee', 'Fiction').
book(1004, 'A Brief History of Time', 'Stephen Hawking', 'Science').

%
:- initialization(server(8080)).
