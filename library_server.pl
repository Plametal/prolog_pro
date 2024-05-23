:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(library_db)).

% ����� ����
:- http_handler(root(.), home_page, []).
:- http_handler(root(books), books_page, []).
:- http_handler(root(checkout), checkout_page, [method(get)]).

% ���� ����
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% Ȩ ������
home_page(_Request) :-
    reply_html_page(
        title('Library Home'),
        [ h1('Welcome to the Library'),
          p('Browse our collection:'),
          a(href('/books'), 'View Books'),
          p('To check out a book,'),
          a(href('/checkout'), 'Click Here')
        ]
    ).

% ���� ��� ������
books_page(_Request) :-
    findall((Barcode, Title, Author, Genre), book(Barcode, Title, Author, Genre), Books),
    reply_html_page(
        title('Book List'),
        [ h1('Book List'),
          \book_list(Books)
        ]
    ).

% ���� ������
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

% ���� ��� ������
book_list([]) --> [].
book_list([(Barcode, Title, Author, Genre)|T]) -->
    html([ li([ 'Barcode: ', Barcode, ', Title: ', Title, ', Author: ', Author, ', Genre: ', Genre ]) ]),
    book_list(T).

% å ���� ó��
:- http_handler(root(checkout), checkout_book_handler, [method(post)]).

checkout_book_handler(Request) :-
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

% ���� ���� ���
:- initialization(server(8080)).
