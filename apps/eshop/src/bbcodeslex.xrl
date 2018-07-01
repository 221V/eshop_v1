%% leex file structure

Definitions.
%W = [A-za-zА-Яа-я0-9]
%L = [A-za-zА-Яа-я0-9.]
%E = [.]

%Tg = [a-z]
%Tag
En = :
%Emoticon
C1 = \[code\]
C2 = \[/code\]

Rules.

%{C1}((.|\n)+?{C2} : {token, {code, TokenLen, TokenChars}}.
{C1}(([^({C1})|({C2})])+([\[\]#])+?(.|\n))+?{C2} : {token, {code, TokenLen, TokenChars}}.

\[b\] : {token, {b, open}}.
\[/b\] : {token, {b, close}}.

\[i\] : {token, {i, open}}.
\[/i\] : {token, {i, close}}.
\[u\] : {token, {u, open}}.
\[/u\] : {token, {u, close}}.
\[s\] : {token, {s, open}}.
\[/s\] : {token, {s, close}}.

\[sub\] : {token, {sub, open}}.
\[/sub\] : {token, {sub, close}}.

\[sup\] : {token, {sup, open}}.
\[/sup\] : {token, {sup, close}}.

\[left\] : {token, {left, open}}.
\[/left\] : {token, {left, close}}.

\[center\] : {token, {center, open}}.
\[/center\] : {token, {center, close}}.

\[right\] : {token, {right, open}}.
\[/right\] : {token, {right, close}}.

\[justify\] : {token, {justify, open}}.
\[/justify\] : {token, {justify, close}}.

\[table\] : {token, {table, open}}.
\[/table\] : {token, {table, close}}.

\[tr\] : {token, {tr, open}}.
\[/tr\] : {token, {tr, close}}.

\[td\] : {token, {td, open}}.
\[/td\] : {token, {td, close}}.


\[hr\] : {token, {hr, open}}.
[\n] : {token, {br, open}}.

\[quote\] : {token, {quote, open}}.
\[/quote\] : {token, {quote, close}}.

\[rtl\] : {token, {rtl, open}}.
\[/rtl\] : {token, {rtl, close}}.

\[ltr\] : {token, {ltr, open}}.
\[/ltr\] : {token, {ltr, close}}.

\[ul\] : {token, {ul, open}}.
\[/ul\] : {token, {ul, close}}.

\[ol\] : {token, {ol, open}}.
\[/ol\] : {token, {ol, close}}.

\[li\] : {token, {li, open}}.
\[/li\] : {token, {li, close}}.

\[font=[A-Za-z\s\-]+?\] : {token, {font_open, TokenLen, TokenChars}}.
\[/font\] : {token, {font, close}}.

\[size=[0-9]+?\] : {token, {size_open, TokenLen, TokenChars}}.
\[/size\] : {token, {size, close}}.

\[color=#[0-9A-Fa-f]+?\] : {token, {color_open, TokenLen, TokenChars}}.
\[/color\] : {token, {color, close}}.

\[img[a-z0-9\s\=]+?\].+?\[/img\] : {token, {img, TokenLen, TokenChars}}.
\[img\] : {token, {img, open}}.
\[/img\] : {token, {img, close}}.

\[email=[A-Za-z0-9\@\.]+?\] : {token, {email_open, TokenLen, TokenChars}}.
\[/email\] : {token, {email, close}}.

\[url=[A-Za-z0-9\@\.\/\:\-\_]+?\].+?\[/url\] : {token, {url, TokenLen, TokenChars}}.
\[youtube\].+?\[/youtube\] : {token, {youtube, TokenLen, TokenChars}}.

:\) : {token, {smile, 1}}.
{En}angel{En} : {token, {smile, 2}}.
{En}angry{En} : {token, {smile, 3}}.
8-\) : {token, {smile, 4}}.
:&#39;\( : {token, {smile, 5}}.
{En}ermm{En} : {token, {smile, 6}}.
:D : {token, {smile, 7}}.
&lt;3 : {token, {smile, 8}}.
:\( : {token, {smile, 9}}.
:O : {token, {smile, 10}}.

:P : {token, {smile, 11}}.
;\) : {token, {smile, 12}}.
{En}alien{En} : {token, {smile, 13}}.
{En}blink{En} : {token, {smile, 14}}.
{En}blush{En} : {token, {smile, 15}}.
{En}cheerful{En} : {token, {smile, 16}}.
{En}devil{En} : {token, {smile, 17}}.
{En}dizzy{En} : {token, {smile, 18}}.
{En}getlost{En} : {token, {smile, 19}}.
{En}happy{En} : {token, {smile, 20}}.
{En}kissing{En} : {token, {smile, 21}}.
{En}ninja{En} : {token, {smile, 22}}.
{En}pinch{En} : {token, {smile, 23}}.
{En}pouty{En} : {token, {smile, 24}}.
{En}sick{En} : {token, {smile, 25}}.
{En}sideways{En} : {token, {smile, 26}}.
{En}silly{En} : {token, {smile, 27}}.
{En}sleeping{En} : {token, {smile, 28}}.
{En}unsure{En} : {token, {smile, 29}}.
{En}woot{En} : {token, {smile, 30}}.
{En}wassat{En} : {token, {smile, 31}}.



[\t]+? : {token, {any_text, TokenLen, TokenChars}}.
[\s]+? : {token, {any_text, TokenLen, TokenChars}}.

%{W}+ : {token, {any_text, TokenLen, TokenChars}}.
%{L}+ : {token, {any_text, TokenLen, TokenChars}}.
%{E}+ : {token, {any_text, TokenLen, TokenChars}}.
%[^\[]+? : {token, {any_text2, TokenLen, TokenChars}}.
[^\[] : {token, {any_text2, TokenChars}}.
[\\\[]+? : {token, {any_text, TokenLen, TokenChars}}.
[\\\]]+? : {token, {any_text, TokenLen, TokenChars}}.


Erlang code.

