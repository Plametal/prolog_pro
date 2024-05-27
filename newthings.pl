:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library_db, [book/4, title_search/2, classification_genre/1,
                      loan_status/2, book_list/0, loan_status_list/0,
                      borrower_list/0, borrower/3, book_status/1,
                      book_loan/0, checkout_book/3, return_book/1] ).
server(Port) :-
    http_server(http_dispatch, [port(Port)]).

%
:- http_handler(root(.), home_page, []).
:- http_handler(root(books), books_page, []).
:- http_handler(root(checkout), checkout_page, []).
:- http_handler(root(search), search, []).
:- use_module(library(http/http_client)).
%


:- use_module(library(http/http_session)).
:- http_handler(root(checkout_handler_book), checkout_handler_book, []).

:- use_module(library(http/html_head)).

:- http_handler(root(title_search_0), title_search_0, []).


:- dynamic post/3.


:- dynamic post/3.

search(Request):-
    (
        http_parameters(Request, [title(Title, [default('None')]), author(Author, [default('None')])], [form_data('')])
        ->  (
                (Title = 'None'; Author = 'None')
                ->  reply_html_page(
                        title('Book Bulletin Board'),
                        [
                            h1('Book Bulletin Board'),
                            div(id(board), []),
                            h2('Please provide both title and author.'),
                            form([action='/checkout_handler_book', method='POST'], % : checkout_handler_book
                                [
                                    label([for='title'], 'Title: '),
                                    input([type=text, id=title, name=title]),
                                    label([for='author'], 'Author: '),
                                    input([type=text, id=author, name=author]),
                                    input([type=submit, value='Add Book'])
                                ]),
                            div(id(posts), []),
                            p(a([href='/'], 'Return to Root'))
                        ]
                    )
                ;   reply_html_page(
                        title('Book Bulletin Board'),
                        [
                            h1('Book Bulletin Board'),
                            div(id(board), []),
                            form([action='/checkout_handler_book', method='POST'], % : checkout_handler_book
                                [
                                    label([for='title'], 'Title: '),
                                    input([type=text, id=title, name=title]),
                                    label([for='author'], 'Author: '),
                                    input([type=text, id=author, name=author]),
                                    input([type=submit, value='Add Book'])
                                ]),
                            div(id(posts), [])
                        ]
                    )
            )
        ;   reply_html_page(
                title('Book Bulletin Board'),
                [
                    h1('Book Bulletin Board'),
                    div(id(board), []),
                    form([action='/checkout_handler_book', method='POST'], % : checkout_handler_book
                        [
                            label([for='title'], 'Title: '),
                            input([type=text, id=title, name=title]),
                            label([for='author'], 'Author: '),
                            input([type=text, id=author, name=author]),
                            input([type=submit, value='Add Book'])
                        ]),
                    div(id(posts), [])
                ]
            )
    ),
    % Print the table of posts
    print_posts_table.

% HTTP handler to handle adding a book

% HTTP handler to handle adding a book
checkout_handler_book(Request) :-
    http_parameters(Request, [title(Title, []), author(Author, [])]),
    assertz(post(Title, Author, 'New book added!')),
    print_posts_table.

% Print the table of posts
print_posts_table :-
    findall(post(Title, Author, _Message), post(Title, Author, _Message), Posts),
    reply_html_page(
        title('Book Bulletin Board'),
        [
            h2('Book Posts'),
            div(style('text-align: center;'),
                table(style('border: 1px dashed; border-collapse: collapse; margin: 0 auto;'),
                    [
                        \posts_table_header,
                        \posts_table_rows(Posts)
                    ]
                )
            ),
            div(style('text-align: center; margin-top: 20px;'),
                form([action='http://localhost:8080/search', method='POST'],
                    input([type='submit', value='Go to User Recommend'])
                )
            ),
            div(style('text-align: center; margin-top: 20px;'),
                form([action='http://localhost:8080', method='POST'],
                    input([type='submit', value='Home'])
                )
            )
        ]
    ).

% Define the header of the posts table
posts_table_header -->
    html(tr([th('Title'), th('Author')])).

% Define the rows of the posts table
posts_table_rows([]) --> [].
posts_table_rows([post(Title, Author, _Message)|Rest]) -->
    html(tr([td(Title), td(Author)])),
    posts_table_rows(Rest).


home_page(_Request) :-


    reply_html_page(
        title('Library Home'),
        [ div(style('text-align: center; height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center;'),
            [ h1('Welcome to the Library'),
              div(style('display: flex; justify-content: center; align-items: center;'),
               [div(style('width: 20vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/books'), 'Book List')),
                div(style('width: 20vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/checkout'), 'CHECK OUT'))
               ]),
              div(style('display: flex; justify-content: center; align-items: center;'),
               [div(style('width: 42vw; height: 20vh; background-color: white; border: 2px dashed black; display: flex; align-items: center; justify-content: center; margin: 1vw;'),
                  a(href('/search'), 'Usr Board'))
               ])
              %div([style('font-size: 1.5em;')], [StatusMessage])
            ])
        ]).
/*
retract_borrower(Name, Phone) :-
    retract(borrower(Name, Phone)).
*/


books_page(_Request):-
    findall((Barcode, Title, Author, Genre), book(Barcode, Title, Author, Genre), Books),
    reply_html_page(
        title('Book List'),
        [   h1('Book List'),
            \book_table(Books),
            div([style='display: flex; flex-direction: column; align-items: center;'],
                [
                    div(style('width: 10vw; height: 5vh; background-color: white; margin: 1vw; display: flex; align-items: center;'),
                        [   form([action='/title_search_0', method='POST'],
                                [   input([name=input, type=text, style('margin-top: 5px;')]),
                                    input([type=submit, value='title search'])
                                ])
                        ]
                    ),
                    div(style('width: 10vw; height: 5vh; background-color: white;  margin: 1vw; display: flex; align-items: center;'),
                        [   form([action='/genre_search_0', method='POST'],
                                [   input([name=input, type=text, style('margin-top: 5px;')]),
                                    input([type=submit, value='genre search'])
                                ])
                        ]
                    ),
                     div(style('text-align: center; border: none; margin-bottom: 1vw;'),
                        form([action='http://localhost:8080'],
                            input([type=submit, value='Home']))
                    )
                ]
            )
        ]
    ).





title_search_0(Request) :-
    http_parameters(Request, [input(Input, [])]),
    (   Input \= '',
        findall((Barcode, Title, Author, Genre, Status), (
            loan_status(Barcode, Status),
            book(Barcode, Title, Author, Genre),
            sub_string(Title, _, _, _, Input),
            book_status(Barcode)
        ), BookList),
        reply_html_page(
            title('Selected Book Information'),
            [   h1('Book Information'),
                \book_table_2(BookList),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080'], input([type=submit, value='Home']))
                    )
                ),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080/books'], input([type=submit, value='Back']))
                    )
                ),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080/checkout'], input([type=submit, value='Borrow section']))
                    )
                )
            ]
        )
    ).



:- http_handler(root(genre_search_0), genre_search_0, []).


genre_search_0(Request) :-
    http_parameters(Request, [input(Input, [])]),
    (   Input \= '',
        findall((Barcode, Title, Author, Genre, Status), (
            loan_status(Barcode, Status),
            book(Barcode, Title, Author, Genre),
            % classification_genre(Genre), % classification_genre
            Genre = Input, %
            book_status(Barcode)
        ), BookList),
        reply_html_page(
            title('Selected Book Information'),
            [   h1('Book Information'),
                \book_table_2(BookList),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080'], input([type=submit, value='Home']))
                    )
                ),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080/books'], input([type=submit, value='Back']))
                    )
                ),
                div([style='display: flex; justify-content: center; align-items: center;'],
                    div([style='text-align: center; border: none;'],
                        form([action='http://localhost:8080/checkout'], input([type=submit, value='Borrow section']))
                    )
                )
            ]
        )
    ).





book_table(Books) -->
    html([
        table([style('margin-left:auto; margin-right:auto; border: 1px dotted black; border-collapse: collapse;')],
            [ tr([th(style('text-align: center;'), 'Barcode'), th(style('text-align: center;'), 'Title'), th(style('text-align: center;'), 'Author'), th(style('text-align: center;'), 'Genre')]) | \book_rows(Books) ])
    ]).

book_rows([]) --> [].
book_rows([(Barcode, Title, Author, Genre)|Rest]) -->
    html(tr([
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Barcode),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Title),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Author),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Genre)
    ])),
    book_rows(Rest).

%checkout page




:- use_module(library(http/http_server)).
:- http_handler(root(checkout), checkout_page, []).
:- http_handler(root(do_checkout), do_checkout, []).


checkout_page(_Request) :-
    reply_html_page(
        title('Checkout Book'),
        [ h1('Checkout Book'),
          div([style('border: 1px dashed black; padding: 10px;')],
              [ p('Input book barcode or title:'),
                form([action='/do_checkout', method='POST'],
                     [ input([name=input, type=text, style('margin-top: 5px;')]),
                       br([]),
                       input([type=submit, value='Checkout'])
                     ])
              ])
        ]
    ).
:- http_handler(root(borrow_usr),borrow_usr , []).
:- http_handler(root(checkout_usr), checkout_usr, []).

do_checkout(Request) :-
    http_parameters(Request, [input(Input, [])]), % HTTP
    (   atom_number(Input, Barcode)
    ->  (   loan_status(Barcode, Status),
            (   Status \= ''
            ->  (   book(Barcode, Title, Author, Genre),
                    reply_html_page(
                        title('selected books'),
                        [ h1('Book Information'),
                          p(['Barcode: ', Barcode]),
                          p(['Book: ', Title]),
                          p(['Author: ', Author]),
                          p(['Genre: ', Genre]),
                          p(['Status: ', Status]),
                          \book_table_2([(Barcode, Title, Author, Genre, Status)]),
                          div([style='display: flex; justify-content: center; align-items: center;'],
                              div([style='text-align: center; border: none;'],
                                  form([action='http://localhost:8080/checkout'],
                                       input([type=submit, value='Back']))
                              )
                          ),

                          div([style='display: flex; justify-content: center; align-items: center;'],
                              div([style='text-align: center; border: none;'],
                                  form([action='http://localhost:8080'],
                                       input([type=submit, value='Home']))
                              )
                          ),
                          div([style='display: flex; justify-content: center; align-items: center;'],
                              div([style='text-align: center; border: none;'],
                                  form([action='http://localhost:8080/borrow_usr'],
                                       input([type=submit, value='Borrow']))
                              )
                          ),
                          div([style='display: flex; justify-content: center; align-items: center;'],
                              div([style='text-align: center; border: none;'],
                                  form([action='http://localhost:8080/checkout_usr'],
                                       input([type=submit, value='Checkout']))
                              )
                          )
                        ]
                    )
                )
            )
        )
    ).
:- http_handler(root(do_borrow), do_borrow, []).
:- http_handler(root(do_return), do_return, []).

borrow_usr(Request) :-
    (   member(method(post), Request)
    ->  http_read_data(Request, Data, []),
        member(name=Name, Data),
        member(phone=Phone, Data),
        member(barcode=BarcodeAtom, Data),
        atom_number(BarcodeAtom, Barcode),
        (   loan_status(Barcode, checked_out)
        ->  Reply = 'Book is already checked out.'
        ;   retractall(loan_status(Barcode, _)),
            assertz(loan_status(Barcode, checked_out)),
            assertz(borrower(Name, Phone, Barcode)),
            Reply = 'Book checked out successfully.'
        ),
        reply_html_page(
            title('Borrow Result'),
            [ h1('Borrow Result'),
              p(Reply),
              form([action='/', method='GET'],

                   [ input([type=submit, value='Home'])
                   ])
            ]
        )
    ;   % GET
        reply_html_page(
            title('Borrow Book'),
            [ h1('Borrow Book'),
              form([action='/borrow_usr', method='POST'],
                   [ p(['Name: ', input([name=name, type=text])]),
                     p(['Phone: ', input([name=phone, type=text])]),
                     p(['Barcode: ', input([name=barcode, type=text])]),
                     p(input([type=submit, value='Borrow']))
                   ])
            ]
        )
    ).

%




/*


*/
% Borrow handler
do_borrow(Request) :-
    member(method(post), Request), !,
    http_read_data(Request, Data, []),
    member(name=Name, Data),
    member(phone=Phone, Data),
    member(barcode=BarcodeAtom, Data),
    atom_number(BarcodeAtom, Barcode),
    (   loan_status(Barcode, checked_out)
    ->  Reply = 'Book is already checked out.'
    ;   retractall(loan_status(Barcode, _)),
        assertz(loan_status(Barcode, checked_out)),
        assertz(borrower(Name, Phone, Barcode)),
        Reply = 'Book checked out successfully.'
    ),
    reply_html_page(
        title('Borrow Result'),
        [ h1('Borrow Result'),
          p(Reply),
          form([action='/', method='GET'],
               [ input([type=submit, value='Home'])
               ])
        ]
    ).


% Checkout user page
checkout_usr(_Request) :-
    reply_html_page(
        title('Checkout Book'),
        [ h1('Checkout Book'),
          div([style('border: 1px dashed black; padding: 10px;')],
              [ p('Input user name, phone number, book barcode:'),
                form([action='/do_return', method='POST'],
                     [ input([name=name, type=text, style('margin-top: 5px;')]),
                       input([name=phone, type=text, style('margin-top: 5px;')]),
                       input([name=barcode, type=text, style('margin-top: 5px;')]),
                       br([]),
                       input([type=submit, value='Return'])
                     ])
              ])
        ]
    ).

% Return handler
do_return(Request) :-
    member(method(post), Request), !,
    http_read_data(Request, Data, []),
    member(name=Name, Data),
    member(phone=Phone, Data),
    member(barcode=BarcodeAtom, Data),
    atom_number(BarcodeAtom, Barcode),
    (   retract(borrower(Name, Phone, Barcode))
    ->  retractall(loan_status(Barcode, _)),
        assertz(loan_status(Barcode, available)),
        Reply = 'Book returned successfully.'
    ;   Reply = 'No matching record found for return.'
    ),
    reply_html_page(
        title('Return Result'),
        [ h1('Return Result'),
          p(Reply),
          form([action='/', method='GET'],
               [ input([type=submit, value='Home'])
               ])
        ]
    ).



book_table_2(Book_check) -->
    html([
        table([style('margin-left:auto; margin-right:auto; border: 1px dotted black; border-collapse: collapse;')],
            [ tr([th(style('text-align: center;'), 'Barcode'), th(style('text-align: center;'), 'Title'), th(style('text-align: center;'), 'Author'), th(style('text-align: center;'), 'Genre'), th(style('text-align: center;'), 'Status')]) | \book_rows_3(Book_check) ])
    ]).

%
book_rows_3([]) --> [].
book_rows_3([(Barcode, Title, Author, Genre, Status)|Rest]) -->
    html(tr([
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Barcode),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Title),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Author),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Genre),
        td([style('border: 1px dotted black; padding: 8px; text-align: center;')], Status)
    ])),
    book_rows_3(Rest).

:- initialization(server(8080)).











