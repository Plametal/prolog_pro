:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(library_db)).

% 라우팅 설정
:- http_handler(root(.), home_page, []).
:- http_handler(root(books), books_page, []).
:- http_handler(root(checkout), checkout_page, [method(get)]).

% 서버 시작
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

% 홈 페이지
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

% 도서 목록 페이지
books_page(_Request) :-
    findall((Barcode, Title, Author, Genre), book(Barcode, Title, Author, Genre), Books),
    reply_html_page(
        title('Book List'),
        [ h1('Book List'),
          \book_list(Books)
        ]
    ).

% 대출 페이지
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

% 도서 목록 렌더링
book_list([]) --> [].
book_list([(Barcode, Title, Author, Genre)|T]) -->
    html([ li([ 'Barcode: ', Barcode, ', Title: ', Title, ', Author: ', Author, ', Genre: ', Genre ]) ]),
    book_list(T).

% 책 대출 처리
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

% 서버 시작 명령
:- initialization(server(8080)).
