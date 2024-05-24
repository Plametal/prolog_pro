/*[book/4, title_search/1, classification_genre/1,
                      loan_status/2, book_list/0, loan_status_list/0,
                      borrower_list/0, borrower/3, book_status/1,
                      book_loan/0, checkout_book/3, return_book/1]
*/
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library_db, [title_search/1]).
:- use_module(library_db, [borrower/3]). %
%
:- http_handler(root(.), home_page, []).
:- http_handler(root(books), books_page, []).
:- http_handler(root(checkout), checkout_page, []).
%:- http_handler(root(info), selecting_book_info, []).
% :- http_handler(root(search), searching_book_list, []).
%
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

%
%
home_page(_Request) :-
    reply_html_page(
        title('Library Home'),
        [ div(style('text-align: center; height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center;'),
            [ h1('Welcome to the Library'),
              div(style('display: flex; justify-content: center; align-items: center;'),
               [div(style('width: 20vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/books'), 'BORROW')),
                div(style('width: 20vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/checkout'), 'CHECK OUT'))
               ]),
              div(style('display: flex; justify-content: center; align-items: center;'),
               [div(style('width: 42vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/search'), 'BOOK LIST'))
               ])
            ])
        ]).
%Borrow
:- use_module(library_db, [book/4]).
books_page(_Request) :-
    findall((Barcode, Title, Author, Genre), book(Barcode, Title, Author, Genre), Books),
    reply_html_page(
        title('Book List'),
        [ h1('Book List'),
          \book_list(Books)
        ]
    ).
/*
books_info(_Request) :-
    reply_html_page(
        title(''), info),
        [ h1('Book info', text_align)]
        ).
*/
      %make selction
      %div(
book_list([]) --> [].
book_list([(Barcode, Title, Author, Genre)|T]) -->
    html([ li([ 'Barcode: ', Barcode, ', Title: ', Title, ', Author: ', Author, ', Genre: ', Genre ]) ]),
    book_list(T).
%checkout page
:- use_module(library_db, [book_status/1]).
:- use_module(library_db, []).
:- http_handler(root(checkout), checkout_page_handler, [method(get)]).
:- http_handler(root(checkout), checkout_book_handler, [method(post)]).

checkout_page(_Request) :-
    reply_html_page(
        title('Checkout Book'),
        [ h1('Checkout Book'),
          form([action='/checkout', method='POST'],
               [ label([for=barcode], 'Enter Book Barcode:'),
                 input([name=barcode, type=text]),
                 br([]),
                 input([type=submit, value='Checkout'])
               ])
        ]
    ).
checkout_page_handler(_Request) :-
    reply_html_page(
        title('Checkout Book'),
        [ h1('Checkout Book'),
          form([action='/checkout', method='POST'],
               [ label([for=barcode], 'Enter Book Barcode:'),
                 input([name=barcode, type=text, id=barcode]),
                 br([]),
                 input([type=submit, value='Checkout'])
               ])
        ]
    ).

checkout_book_handler(_Request) :-
    http_parameters(Request,
                    [ barcode(Barcode, [atom]),
                      [name(Name, [default('unknown')]),
                       phone(Phone, [default('unknown')])
                      ]
                    ]),
    checkout_book(Name, Phone, Barcode),
    reply_html_page(
        title('Checkout Confirmation'),
        [ h1('Checkout Confirmation'),
          p('Book checked out successfully.'),
          p('Thank you for using our library!')
        ]
    ).


%
:- initialization(server(8080)).
