:- module(html_handlers, [an_inclusion//0]).
/** <module> Handlers that use the built in html generation */

%
:- use_module(library(http/http_dispatch)).

% HTML
:- use_module(library(http/html_write)).

% borders
:- use_module(fancy_borders).

%     .        .
:- http_handler(root(pagedemo), page_demo , []).

%% page_demo(+Request:request) is det
% 'termerized html'
page_demo(_Request) :-
    reply_html_page(
        title('Strangeloop Rocks!'),
        div([h1('Strangeloop Rocks'),
             p('This page was generated from termerized html')
            ])).

:- http_handler(root(lotsofsyntax), lots_of_syntax , []).

%% lots_of_syntax(+Request:request) is det
%  'termerized html'
lots_of_syntax(_Request) :-
    reply_html_page(
        title('Lots of Syntax'),
        \syntax_demo).

%% syntax_demo is det
% termerized HTML      DCG
syntax_demo -->
    {
        Foo = 3,
        Name = 'Anne Ogborn',
        Age = 28,
        MyMessage = 'howdy there'
    },
    html([
        p('   '),
        p([' ', b(''), '  ']),
        p([style('color: #ff0000'), title(' ')],
          'arity 2   '),
        '<b>   </b>',
        p([' ', &(copy), '  ']),
        \['<p>   ( )</p>'],
        p('  ~w '-[Foo]),
        p(a(href('mep.php?'+[name=Name, age=Age]), '')),
        p(a(href('http://example.com/foo.php?msg='+encode(MyMessage)),
          'encode     ')),
        p(a(href(location_by_id(zippy)),
            'ID    (  )')),
        p(class([bar, baz, mep]), ' 3  '),
        \an_inclusion,
        \fancy_border('border: 1px dotted black;', \an_inclusion),
        \an_inclusion_with_qq
    ]).

%% an_inclusion is det
% html//1
%  .
an_inclusion -->
    inclusion_a,
    inclusion_b.

%% inclusion_a is det
%
%  'termerized html'  html//1 .
inclusion_a -->
    html(p('inclusion a')).
inclusion_b -->
    html(p('inclusion b')).

%% an_inclusion_with_qq is det
% HTML
% html quasiquote
an_inclusion_with_qq -->
    {
        Foo = mep
    },
    html([
        p('  quasiquotes  .'),
        html({|html(Foo)||<p>Foo</p>|})
    ]).
