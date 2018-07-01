-module(hm).
-compile([export_all, nowarn_export_all]).

%-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").
%-include_lib("kernel/include/file.hrl").

%help module


%% get params

% get_language_from_header(Req)
% get_language_from_cookies(Name, Req)
% get_language(Name, Req)


%% validations

% is_valid_post_id(A)
% is_valid_binnumber(A)
% is_valid_email(A)
% 


%% trim

% trim(Bin)
% trim_l(List)


%% input data changing

% get_main_page_number(A)
% get_post_number(A)
% get_number_fromgetparam(A)
% htmlspecialchars(String)
% tags_to_values(Data,Acc)
% hash_pass(A)
% order_goods_info2tuples(Data_Ids,Data,Acc)
% balance_int2bin(V)
% input_balance_valid(V)
% input_count_valid(V)
% input_balance2int(V)
% bin2hstorepairs(Data,Acc)
% update_goods_rates(Goods_Info2)
% 

%% upload files callback

% filename(#ftp{})
% get_filepath_by_meta(Meta)

%% telegram

% telegram_send_message(Message)


%% other

% timestamp2binary({{Year,Month,Day},{Hour,Minit,_}})
% date2list({{Year,Month,Day},_})
% is_substr(Str,SubStr)
% leex_parser(List, Acc)
% leex_parser2({Token_Type, Token_Type2} | {Token_Type, TokenLen, TokenChars} | {Token_Type, TokenChars})
% getbbfont(String)
% getbbsize(String)
% getbbcolor(String)
% getbbsmile(Int)
% 

%%%%%%%%%%%%%%%%


%% get params

get_language_from_header(Req) ->
  {Headers,_} = wf:headers(Req),
  Accept_language = [ V || {K,V} <- Headers, K =:= <<"accept-language">> ],
  case Accept_language of
    [] ->
      <<"en">>;
    [H|_] ->
      <<Lang:2/binary,_/binary>> = H,
      case lists:member(Lang, [<<"en">>,<<"uk">>,<<"ru">>]) of
        false -> <<"en">>;
        true -> Lang
      end
  end.


get_language_from_cookies(Name, Req) ->
  case wf:cookie_req(Name,Req) of
    undefined ->
      false;
    Lang ->
      case lists:member(Lang, [<<"en">>,<<"uk">>,<<"ru">>]) of
        false -> false;
        true -> Lang
      end
  end.


get_language(Name, Req) ->
  case ?MODULE:get_language_from_cookies(Name, Req) of
    false ->
      ?MODULE:get_language_from_header(Req);
    Lang ->
      Lang
  end.


%% validations

is_valid_post_id(A) ->
  case re:run(A, <<"^/post/[1-9]{1}([0-9])*$"/utf8>>, [unicode]) of
    nomatch ->
      false;
    _ ->
      true
  end.


is_valid_binnumber(A) ->
  case re:run(A, <<"^[1-9]{1}([0-9])*$"/utf8>>, [unicode]) of
    nomatch ->
      false;
    _ ->
      true
  end.


is_valid_email(A) ->
  %case re:run(A, "^[a-z0-9_-]+(\.[a-z0-9_-]+)*@([0-9a-z][0-9a-z-]*[0-9a-z]\.)+([a-z]{2,8})$") of
  case re:run(A, "^(.)+@(.)+\.(.+)$") of
    nomatch -> false;
    _ -> true
  end.


%% trim

%trim binary
trim(<<>>) -> <<>>;
trim(Bin = <<C,BinTail/binary>>) ->
  case ?MODULE:is_whitespace(C) of
    true -> ?MODULE:trim(BinTail);
    false -> ?MODULE:trim_tail(Bin)
  end.

trim_tail(<<>>) -> <<>>;
trim_tail(Bin) ->
  Size = erlang:size(Bin) - 1,
  <<BinHead:Size/binary,C>> = Bin,
  case ?MODULE:is_whitespace(C) of
    true -> ?MODULE:trim_tail(BinHead);
    false -> Bin
  end.

%helper - trim symbols
is_whitespace($\s) -> true;
is_whitespace($\t) -> true;
is_whitespace($\n) -> true;
is_whitespace($\r) -> true;
is_whitespace(_) -> false.

%trim list
trim_l("") -> "";
trim_l(List=[H|T]) ->
  case ?MODULE:is_whitespace(H) of
    true -> ?MODULE:trim_l(T);
    false -> ?MODULE:trim_tail_l(lists:reverse(List))
  end.

trim_tail_l("") -> "";
trim_tail_l(List=[H|T]) ->
  case ?MODULE:is_whitespace(H) of
    true -> ?MODULE:trim_tail_l(T);
    false -> lists:reverse(List)
end.


%% input data changing

get_main_page_number(A) ->
  % <<"/page/777">> or <<"/ws/page/777">>
  [_,N|_] = string:split(A, <<"/">>, trailing),
  erlang:binary_to_integer(N).


get_post_number(A) ->
  % <<"/post/3">>
  [_,N|_] = string:split(A, <<"/">>, trailing),
  erlang:binary_to_integer(N).


get_number_fromgetparam(undefined) ->
  {false, <<"">>};
get_number_fromgetparam(A) ->
  case ?MODULE:is_valid_binnumber(A) of
    true ->
      {true, erlang:binary_to_integer(A)};
    _ ->
      {false, <<"">>}
  end.


htmlspecialchars(String) ->
  unicode:characters_to_binary( [?MODULE:htmlspecialchars2(X) || X <- String], utf8, latin1).

%helper
% & -> &amp;, " -> &quot;, ' -> &apos;, < -> &lt;, > -> &gt;
htmlspecialchars2($&) -> "&amp;";
htmlspecialchars2($") -> "&quot;";
%htmlspecialchars2($') -> "&apos;";
htmlspecialchars2($') -> "&#39;";
htmlspecialchars2($<) -> "&lt;";
htmlspecialchars2($>) -> "&gt;";
htmlspecialchars2($|) -> "&#124;";
htmlspecialchars2($`) -> "&#96;";
htmlspecialchars2(A) -> A.
%"


%tags_to_values(Data,Acc) ->
tags_to_values([],Acc) -> Acc;
tags_to_values([H],Acc) ->
  case re:run(H, "^[0-9]{1,}$") of
    nomatch -> Acc;
    _ ->
      case Acc of
        "" -> H;
        _ -> H ++ "," ++ Acc
      end
  end;
tags_to_values([H|T],Acc) ->
  case re:run(H, "^[0-9]{1,}$") of
    nomatch -> ?MODULE:tags_to_values(T,Acc);
    _ ->
      case Acc of
        "" -> ?MODULE:tags_to_values(T,H);
        _ -> ?MODULE:tags_to_values(T,H ++ "," ++ Acc)
      end
  end.


%make hash pass
hash_pass(A) ->
  S1 = <<"Some хорош salt!\"@#ф$%iі^&*()=="/utf8>>,
  S2 = <<"yeah ____________<>(c)2018++lol"/utf8>>,
  A2 = erlang:list_to_binary(A),
  [ erlang:element(C+1, {$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F}) || <<C:4>> <= crypto:hash(sha512, <<S1/binary,A2/binary,S2/binary>>)].


%order_goods_info2tuples(Data_Ids,Data,Acc)
order_goods_info2tuples([],Data,[]) ->
  % no ids yet, no results acc  
  Data_Ids = ?MODULE:order_goods_info2tuples_helper1(Data,[]),
  %io:format("ids: ~p~n",[Data_Ids]),
  ?MODULE:order_goods_info2tuples(Data_Ids, Data, []);
order_goods_info2tuples([],_,Acc) ->
  % we have results acc and no more ids
  Acc;
order_goods_info2tuples([Id|T],Data,Acc) ->
  % we have ids, we work for results acc
  %io:format("id, data: ~p ~p~n",[Id, Data]),
  [{_,Name,_,_,_,_,_,_,_,_,_,_}|_] = pq:get_goods_adminka_by_id(erlang:binary_to_integer(Id)),
  Count = order_goods_info2tuples_helper2(<<"count">>, Id, Data),
  Price = order_goods_info2tuples_helper2(<<"price">>, Id, Data),
  % we create list like [{<<"Id">>, <<"name_value">>, <<"count_value">>, <<"price_value">>}, ...]
  ?MODULE:order_goods_info2tuples(T, Data, [{Id,Name,Count,Price}|Acc]).

%helper -- get ids
%order_goods_info2tuples_helper1(Data,Acc)
order_goods_info2tuples_helper1([],Acc) ->
  Acc;
order_goods_info2tuples_helper1([{<<"id", _/binary>>,Id}|T],Acc) ->
  % here Id is binary type
  ?MODULE:order_goods_info2tuples_helper1(T,[Id|Acc]);
order_goods_info2tuples_helper1([_|T],Acc) ->
  ?MODULE:order_goods_info2tuples_helper1(T,Acc).

%helper -- get value by id & key
%order_goods_info2tuples_helper2(Key, Id, Data)
order_goods_info2tuples_helper2(_, _, []) ->
  <<"">>;
order_goods_info2tuples_helper2(Key, Id, [{Key2, V}|T]) ->
  if Key2 =:= <<Key/binary, Id/binary>> ->
      %io:format("kih: ~p ~p ~p ~n",[Key,Id,Key2]),
      V;
    true ->
      %io:format("kih: ~p ~p ~p ~p ~n",[Key,Id, Key2,<<"===">>]),
      ?MODULE:order_goods_info2tuples_helper2(Key, Id, T)
  end.


%575 -> <<"5.75">>
balance_int2bin(V) ->
  if V =:= 0 ->
      <<"0.00">>;
    V =:= 100 ->
      <<"1.00">>;
    V < 100 ->
      erlang:list_to_binary("0." ++ erlang:integer_to_list(V));
    V > 100 ->
      V0 = erlang:integer_to_list(V),
      VL = erlang:length(V0) - 2,
      erlang:list_to_binary(string:sub_string(V0,1,VL) ++ "." ++ string:sub_string(V0,VL+1))
  end.


%"5.45"
%"5"
%<<"5.45">>
%<<"5">>
input_balance_valid(V) when erlang:is_list(V) ->
  case re:run(V, "^[0-9]{1,}[\.]{1}[0-9]{1,2}$") of
    nomatch ->
      case re:run(V, "^[0-9]{1,15}$") of
        nomatch ->
          false;
        _ ->
          case erlang:list_to_integer(V) =:= 0 of
            true -> false;
            _ -> true
          end
      end;
    _ ->
      case ((V =/= "0.0") and (V =/= "0.00")) of
        true -> true;
        _ -> false
      end
  end;
input_balance_valid(V) when erlang:is_binary(V) ->
  case re:run(V, <<"^[0-9]{1,}[\.]{1}[0-9]{1,2}$">>) of
    nomatch ->
      case re:run(V, <<"^[0-9]{1,15}$">>) of
        nomatch ->
          false;
        _ ->
          case erlang:binary_to_integer(V) =:= 0 of
            true -> false;
            _ -> true
          end
      end;
    _ ->
      case ((V =/= <<"0.0">>) and (V =/= <<"0.00">>)) of
        true -> true;
        _ -> false
      end
  end;
input_balance_valid(_) ->
  false.


input_count_valid(V) when erlang:is_list(V) ->
  case re:run(V, "^[0-9]{1,20}$") of
    nomatch ->
      false;
    _ ->
      case erlang:list_to_integer(V) =:= 0 of
        true -> false;
        _ -> true
      end
  end;
input_count_valid(V) when erlang:is_binary(V) ->
  case re:run(V, <<"^[0-9]{1,20}$">>) of
    nomatch ->
      false;
    _ ->
      case erlang:binary_to_integer(V) =:= 0 of
        true -> false;
        _ -> true
      end
  end;
input_count_valid(_) -> false.


%"5.45" -> 545
%"5" -> 500
%<<"5.45">> -> 545
%<<"5">> -> 500
input_balance2int(V) when erlang:is_list(V) ->
  %list string
  [R1|T] = string:split(V,"."),
  case T =:= [] of
    true ->
      erlang:list_to_integer(R1) * 100;
    _ ->
      [R2|_] = T,
      erlang:list_to_integer(R1) * 100 + erlang:list_to_integer(R2)
  end;
input_balance2int(V) when erlang:is_binary(V) ->
  %binary string
  [R1|T] = binary:split(V, <<".">>),
  case T =:= [] of
    true ->
      erlang:binary_to_integer(R1) * 100;
    _ ->
      [R2|_] = T,
      erlang:binary_to_integer(R1) * 100 + erlang:binary_to_integer(R2)
  end.


% bin2hstorepairs(Data,Acc)
bin2hstorepairs([],Acc) ->
  {Acc};
bin2hstorepairs([Id,Count|T],Acc) ->
  [{_, _, _, _, _, _, _, _, _, Price, _, _}] = pq:get_goods_adminka_by_id(erlang:binary_to_integer(Id)),
  
  Acc1 = [{ <<"id", Id/binary>>, Id }|Acc],
  Acc2 = [{ <<"price", Id/binary>>, erlang:integer_to_binary(Price) }|Acc1],
  Acc3 = [{ <<"count", Id/binary>>, Count }|Acc2],
  ?MODULE:bin2hstorepairs(T,Acc3).


update_goods_rates({Goods_Info3}) ->
  Bin_Data_Ids = ?MODULE:order_goods_info2tuples_helper1(Goods_Info3,[]),
  ?MODULE:update_goods_rates2(Bin_Data_Ids).

update_goods_rates2([]) -> ok;
update_goods_rates2([Bin_Id|T]) ->
  pq:upd_good_rate_by_id(erlang:binary_to_integer(Bin_Id)),
  ?MODULE:update_goods_rates2(T).


%% upload files callback

%filename(#ftp{})
% -record(ftp,     { id, sid, filename, meta, size, offset, block, data, status }).
filename(#ftp{sid=_Sid,meta=Meta,filename=FileName}) ->
  %io:format("filename callback Sid: ~p~n",[Sid]), % filename callback Sid: <<"77f43aeee51eb84879d5735dc21c7ec6">>
  %io:format("filename callback Meta: ~p~n",[Meta]), % filename callback Meta: <<>> || "upload_form_1" || "777" || "mini1-777" || "micro1-777"
  %io:format("filename callback FileName: ~p~n",[FileName]), % filename callback FileName: <<"0YCC-AKyRnxWFf5vC.jpg">>
  %filename:join(wf:to_list(Sid),FileName).
  {Type,PathName} = ?MODULE:get_filepath_by_meta(Meta),
  PathFileName = filename:join(PathName,FileName),
  if Type =:= "mini" ->
      file:delete("/var/www/eshop/uploads/" ++ erlang:binary_to_list(PathFileName));
    Type =:= "micro" ->
      file:delete("/var/www/eshop/uploads/" ++ erlang:binary_to_list(PathFileName));
    true -> ok
  end,
  
  %filename:join(PathName,FileName).
  %io:format("::~p~n",[PathFileName]),
  PathFileName.

%get_filepathname_by_metaname(Meta)
get_filepath_by_meta([$m,$i,$n,$i|Meta2]) ->
  % previev2 - mini -- for lightbox
  [D,G|_] = string:split(Meta2,"|"),
  {"mini",["imgs/", D, "/", G, "/mini"]};
get_filepath_by_meta([$m,$i,$c,$r,$o|Meta2]) ->
  % preview2 - micro -- for cart
  [D,G|_] = string:split(Meta2,"|"),
  {"micro",["imgs/", D, "/", G, "/micro"]};
get_filepath_by_meta(Meta) ->
  % full img
  {"full",["imgs/", ?MODULE:date2list(calendar:local_time()), "/", Meta]}.


%% telegram

telegram_send_message(Message) ->
  ssl:start(),
  %application:start(ssl),
  application:start(inets),
  
  Tg_Token = wf:config(n2o,tg_token,"0"),
  Tg_Chat_Id = wf:config(n2o,tg_chat_id,"0"),
  
  Message2 = http_uri:encode(unicode:characters_to_binary(Message,utf8)),
  
  %Userdata = "chat_id=" ++ Tg_Chat_Id  ++ "&text=" ++ Message2,
  Userdata = <<"chat_id=", (erlang:list_to_binary(Tg_Chat_Id))/binary, "&text=", Message2/binary>>,
  Url = "https://api.telegram.org/bot" ++ Tg_Token ++ "/sendMessage",
  %{ok,{{Status,Code,State},Headers,Body}} = httpc:request(post,{Url, [], "application/x-www-form-urlencoded", Userdata}, [], []),
  {Status,_} = httpc:request(post,{Url, [], "application/x-www-form-urlencoded", Userdata}, [], []),
  Status.


%% other

%{{2017,10,18},{12,29,50.0}}
timestamp2binary({{Year,Month,Day},{Hour,Minit,_}}) ->
  [erlang:integer_to_binary(Year), <<"/">>, ?MODULE:make_valid_day(Month), <<"/">>, ?MODULE:make_valid_day(Day), <<" ">>, ?MODULE:make_valid_day(Hour), <<":">>, ?MODULE:make_valid_day(Minit)].

date2list({{Year,Month,Day},_}) ->
  [erlang:integer_to_list(Year), "/", ?MODULE:make_valid_day_list(Month), "/", ?MODULE:make_valid_day_list(Day) ].

%helper
make_valid_day(Data) when Data < 10 ->
  [<<"0">>, erlang:integer_to_binary(Data)];
make_valid_day(Data) ->
  erlang:integer_to_binary(Data).

%helper2
make_valid_day_list(Data) when Data < 10 ->
  "0" ++ erlang:integer_to_list(Data);
make_valid_day_list(Data) ->
  erlang:integer_to_list(Data).


is_substr(Str,SubStr) ->
  Pos = string:str(Str,SubStr),
  if Pos > 0 -> true;
    true -> false
  end.


% leex_parser(List, Acc)
leex_parser([], Acc) -> lists:reverse(Acc);
leex_parser([H|T], Acc) ->
  Res = ?MODULE:leex_parser2(H),
  ?MODULE:leex_parser(T,[Res|Acc]).


%leex_parser2({Token_Type, TokenChars})
leex_parser2({any_text2, TokenChars}) -> TokenChars;

%leex_parser2({Token_Type, Token_Type2})
leex_parser2({b, open}) -> <<"<b>">>;
leex_parser2({b, close}) -> <<"</b>">>;
leex_parser2({i, open}) -> <<"<i>">>;
leex_parser2({i, close}) -> <<"</i>">>;
leex_parser2({u, open}) -> <<"<u>">>;
leex_parser2({u, close}) -> <<"</u>">>;
leex_parser2({s, open}) -> <<"<s>">>;
leex_parser2({s, close}) -> <<"</s>">>;
leex_parser2({sub, open}) -> <<"<sub>">>;
leex_parser2({sub, close}) -> <<"</sub>">>;
leex_parser2({sup, open}) -> <<"<sup>">>;
leex_parser2({sup, close}) -> <<"</sup>">>;
leex_parser2({left, open}) -> <<"<div class=\"left\">">>;
leex_parser2({left, close}) -> <<"</div>">>;
leex_parser2({center, open}) -> <<"<div class=\"center\">">>;
leex_parser2({center, close}) -> <<"</div>">>;
leex_parser2({right, open}) -> <<"<div class=\"right\">">>;
leex_parser2({right, close}) -> <<"</div>">>;
leex_parser2({justify, open}) -> <<"<div class=\"justify\">">>;
leex_parser2({justify, close}) -> <<"</div>">>;
leex_parser2({table, open}) -> <<"<table>">>;
leex_parser2({table, close}) -> <<"</table>">>;
leex_parser2({tr, open}) -> <<"<tr>">>;
leex_parser2({tr, close}) -> <<"</tr>">>;
leex_parser2({td, open}) -> <<"<td>">>;
leex_parser2({td, close}) -> <<"</td>">>;
leex_parser2({hr, open}) -> <<"<hr>">>;
leex_parser2({br, open}) -> <<"<br>">>;
leex_parser2({quote, open}) -> <<"<blockquote>">>;
leex_parser2({quote, close}) -> <<"</blockquote>">>;
leex_parser2({rtl, open}) -> <<"<div class=\"rtl\">">>;
leex_parser2({rtl, close}) -> <<"</div>">>;
leex_parser2({ltr, open}) -> <<"<div class=\"ltr\">">>;
leex_parser2({ltr, close}) -> <<"</div>">>;
leex_parser2({ul, open}) -> <<"<ul>">>;
leex_parser2({ul, close}) -> <<"</ul>">>;
leex_parser2({ol, open}) -> <<"<ol>">>;
leex_parser2({ol, close}) -> <<"</ol>">>;
leex_parser2({li, open}) -> <<"<li>">>;
leex_parser2({li, close}) -> <<"</li>">>;
leex_parser2({img, open}) -> <<"<img src=\"">>;
leex_parser2({img, close}) -> <<"\">">>;
leex_parser2({font, close}) -> <<"</span>">>;
leex_parser2({size, close}) -> <<"</span>">>;
leex_parser2({color, close}) -> <<"</span>">>;
leex_parser2({email, close}) -> <<"</a>">>;
leex_parser2({smile, Int}) -> ?MODULE:getbbsmile(Int);

%leex_parser2({Token_Type, TokenLen, TokenChars})
leex_parser2({code, TokenLen, TokenChars}) ->
  % \[code\].+?\[/code\]
  case TokenLen of
    13 -> <<"">>;
    _ -> [ <<"<pre class=\"prettyprint\">">>, string:slice(TokenChars, 6, TokenLen - 13), <<"</pre>">> ]
  end;
leex_parser2({font_open, TokenLen, TokenChars}) ->
  % \[font=[A-Za-z\s\-]+?\]
  case TokenLen of
    7 -> <<"">>;
    _ -> [ <<"<span class=\"bbfont_">>, string:slice(TokenChars, 6, TokenLen - 7), <<"\">">> ]
  end;
leex_parser2({size_open, TokenLen, TokenChars}) ->
  % \[size=[0-9]+?\]
  case TokenLen of
    7 -> <<"">>;
    _ -> [ <<"<span class=\"bbfontsize_">>, ?MODULE:getbbsize(string:slice(TokenChars, 6, TokenLen - 7)), <<"\">">> ]
  end;
leex_parser2({color_open, TokenLen, TokenChars}) ->
  % \[color=#[0-9A-Fa-f]+?\]
  case TokenLen of
    9 -> <<"">>;
    _ -> [ <<"<span class=\"bbcolor_">>, ?MODULE:getbbcolor(string:slice(TokenChars, 7, TokenLen - 8)), <<"\">">> ]
  end;
leex_parser2({img, TokenLen, TokenChars}) ->
  % \[img[a-z0-9\s\=]+?\].+?\[/img\]
  
  % [img width=55], [img height=55], [img width=55 height=77], [img=55x77] - width x height , [/img]
  % <img src="http://zzz.ua/img/zzz.jpg" width="55" height="77">
  TokenChars2 = string:slice(TokenChars, 5, TokenLen - 10),
  
  case re:run(TokenChars2, "^width=[0-9]+?\\].+$") of
    nomatch ->
      case re:run(TokenChars2, "^height=[0-9]+?\\].+$") of
        nomatch ->
          case re:run(TokenChars2, "^width=[0-9]+?[\\s]height=[0-9]+?\\].+$") of
            nomatch ->
              case re:run(TokenChars2, "^[0-9]+?x[0-9]+?\\].+$") of
                nomatch -> <<"">>;
                _ ->
                  re:replace(TokenChars2, "^([0-9]+?)x([0-9]+?)\\](.+)$", "<img src=\"\\3\" width=\"\\1\" height=\"\\2\">", [global, dotall, caseless])
              end;
            _ ->
              re:replace(TokenChars2, "^width=([0-9]+?)[\\s]height=([0-9]+?)\\](.+)$", "<img src=\"\\3\" width=\"\\1\" height=\"\\2\">", [global, dotall, caseless])
          end;
        _ -> re:replace(TokenChars2, "^height=([0-9]+?)\\](.+)$", "<img src=\"\\2 height=\"\\1\">", [global, dotall, caseless])
      end;
    _ -> re:replace(TokenChars2, "^width=([0-9]+?)\\](.+)$", "<img src=\"\\2 width=\"\\1\">", [global, dotall, caseless])
  end;
leex_parser2({email_open, TokenLen, TokenChars}) ->
  % \[email=[A-Za-z0-9\@\.]+?\]
  [ <<"<a href=\"mailto:">>, string:slice(TokenChars, 7, TokenLen - 8), <<"\">">> ];
leex_parser2({url, _TokenLen, TokenChars}) ->
  % \[url=[A-Za-z0-9\@\.\/\:\-\_]+?\].+?\[/url\]
  re:replace(TokenChars, "\\[url=([\\w\\d\\@\\.\\/\\:\\_\\-]+?)\\](.+?)\\[/url\\]", "<a href=\"\\1\" target=\"_blank\">\\2</a>", [global, dotall, caseless]);
leex_parser2({youtube, _TokenLen, TokenChars}) ->
  % \[youtube\].+?\[/youtube\]
  
  % [youtube]4_2qNABaZOE[/youtube]
  % <iframe src="https://www.youtube.com/embed/4_2qNABaZOE?wmode=opaque" data-youtube-id="4_2qNABaZOE" allowfullscreen="" width="560" height="315" frameborder="0"></iframe>
  
  % https://www.youtube.com/watch?v=4_2qNABaZOE
  % https://youtu.be/4_2qNABaZOE -> https://www.youtube.com/watch?v=4_2qNABaZOE&feature=youtu.be
  % https://youtu.be/4_2qNABaZOE?t=20s -> https://www.youtube.com/watch?v=4_2qNABaZOE&feature=youtu.be&t=20s
  % <iframe width="560" height="315" src="https://www.youtube.com/embed/4_2qNABaZOE" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe>
  % <iframe width="560" height="315" src="https://www.youtube.com/embed/4_2qNABaZOE?start=20" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe>

  % todo - fix/add starttime in sceditor and here
  
  re:replace(TokenChars, "\\[youtube\\](.*?)\\[/youtube\\]", "<iframe width=\"560\" height=\"315\" src=\"https://www.youtube.com/embed/\\1\" frameborder=\"0\" gesture=\"media\" allow=\"encrypted-media\" allowfullscreen></iframe>", [global, dotall, caseless]);

leex_parser2({any_text, _, TokenChars}) -> TokenChars.


%getbbfont(String)
%getbbfont("Arial") -> "arial";
getbbfont("Arial Black") -> "arialblack";
getbbfont("Comic Sans MS") -> "comicsansms";
getbbfont("Courier New") -> "couriernew";
getbbfont("Georgia") -> "georgia";
getbbfont("Impact") -> "impact";
getbbfont("Sans-serif") -> "sansserif";
getbbfont("Serif") -> "serif";
getbbfont("Times New Roman") -> "timesnewroman";
getbbfont("Trebuchet MS") -> "trebuchetms";
getbbfont("Verdana") -> "verdana";
getbbfont(_) -> "arial".


%getbbsize(String)
getbbsize("1") -> "1";
getbbsize("2") -> "2";
%getbbsize("3") -> "3";
getbbsize("4") -> "4";
getbbsize("5") -> "5";
getbbsize("6") -> "6";
getbbsize("7") -> "7";
getbbsize(_) -> "3".


%getbbcolor(String)
getbbcolor("#000000") -> "1";
getbbcolor("#44B8FF") -> "2";
getbbcolor("#1E92F7") -> "3";
getbbcolor("#0074D9") -> "4";
getbbcolor("#005DC2") -> "5";
getbbcolor("#00369B") -> "6";
getbbcolor("#b3d5f4") -> "7"; % look for todo in mybbcodes.css
getbbcolor("#444444") -> "8";
getbbcolor("#C3FFFF") -> "9";
getbbcolor("#9DF9FF") -> "10";
getbbcolor("#7FDBFF") -> "11";
getbbcolor("#68C4E8") -> "12";
getbbcolor("#419DC1") -> "13";
getbbcolor("#d9f4ff") -> "14";
getbbcolor("#666666") -> "15";
getbbcolor("#72FF84") -> "16";
getbbcolor("#4CEA5E") -> "17";
getbbcolor("#2ECC40") -> "18";
getbbcolor("#17B529") -> "19";
getbbcolor("#008E02") -> "20";
getbbcolor("#c0f0c6") -> "21";
getbbcolor("#888888") -> "22";
getbbcolor("#FFFF44") -> "23";
getbbcolor("#FFFA1E") -> "24";
getbbcolor("#FFDC00") -> "25";
getbbcolor("#E8C500") -> "26";
getbbcolor("#C19E00") -> "27";
getbbcolor("#fff5b3") -> "28";
getbbcolor("#aaaaaa") -> "29";
getbbcolor("#FFC95F") -> "30";
getbbcolor("#FFA339") -> "31";
getbbcolor("#FF851B") -> "32";
getbbcolor("#E86E04") -> "33";
getbbcolor("#C14700") -> "34";
getbbcolor("#ffdbbb") -> "35";
getbbcolor("#cccccc") -> "36";
getbbcolor("#FF857A") -> "37";
getbbcolor("#FF5F54") -> "38";
getbbcolor("#FF4136") -> "39";
getbbcolor("#E82A1F") -> "40";
getbbcolor("#C10300") -> "41";
getbbcolor("#ffc6c3") -> "42";
getbbcolor("#eeeeee") -> "43";
getbbcolor("#FF56FF") -> "44";
getbbcolor("#FF30DC") -> "45";
getbbcolor("#F012BE") -> "46";
getbbcolor("#D900A7") -> "47";
getbbcolor("#B20080") -> "48";
getbbcolor("#fbb8ec") -> "49";
getbbcolor("#ffffff") -> "50";
getbbcolor("#F551FF") -> "51";
getbbcolor("#CF2BE7") -> "52";
getbbcolor("#B10DC9") -> "53";
getbbcolor("#9A00B2") -> "54";
%getbbcolor("#9A00B2") -> "55"; % look for todo in mybbcodes.css
getbbcolor("#e8b6ef") -> "56";
getbbcolor(_) -> "1".


%getbbsmile(Int)
getbbsmile(1) -> <<"<img src=\"/img/emoticons/smile.png\" alt=\":)\" title=\":)\">">>;
getbbsmile(2) -> <<"<img src=\"/img/emoticons/angel.png\" alt=\":angel:\" title=\":angel:\">">>;
getbbsmile(3) -> <<"<img src=\"/img/emoticons/angry.png\" alt=\":angry:\" title=\":angry:\">">>;
getbbsmile(4) -> <<"<img src=\"/img/emoticons/cool.png\" alt=\"8-)\" title=\"8-)\">">>;
getbbsmile(5) -> <<"<img src=\"/img/emoticons/cwy.png\" alt=\":&#39;(\" title=\":&#39;(\">">>;
getbbsmile(6) -> <<"<img src=\"/img/emoticons/ermm.png\" alt=\":ermm:\" title=\":ermm:\">">>;
getbbsmile(7) -> <<"<img src=\"/img/emoticons/grin.png\" alt=\":D\" title=\":D\">">>;
getbbsmile(8) -> <<"<img src=\"/img/emoticons/heart.png\" alt=\"&lt;3\" title=\"&lt;3\">">>;
getbbsmile(9) -> <<"<img src=\"/img/emoticons/sad.png\" alt=\":(\" title=\":(\">">>;
getbbsmile(10) -> <<"<img src=\"/img/emoticons/shocked.png\" alt=\":O\" title=\":O\">">>;
getbbsmile(11) -> <<"<img src=\"/img/emoticons/tongue.png\" alt=\":P\" title=\":P\">">>;
getbbsmile(12) -> <<"<img src=\"/img/emoticons/wink.png\" alt=\";)\" title=\";)\">">>;
getbbsmile(13) -> <<"<img src=\"/img/emoticons/alien.png\" alt=\":alien:\" title=\":alien:\">">>;
getbbsmile(14) -> <<"<img src=\"/img/emoticons/blink.png\" alt=\":blink:\" title=\":blink:\">">>;
getbbsmile(15) -> <<"<img src=\"/img/emoticons/blush.png\" alt=\":blush:\" title=\":blush:\">">>;
getbbsmile(16) -> <<"<img src=\"/img/emoticons/cheerful.png\" alt=\":cheerful:\" title=\":cheerful:\">">>;
getbbsmile(17) -> <<"<img src=\"/img/emoticons/devil.png\" alt=\":devil:\" title=\":devil:\">">>;
getbbsmile(18) -> <<"<img src=\"/img/emoticons/dizzy.png\" alt=\":dizzy:\" title=\":dizzy:\">">>;
getbbsmile(19) -> <<"<img src=\"/img/emoticons/getlost.png\" alt=\":getlost:\" title=\":getlost:\">">>;
getbbsmile(20) -> <<"<img src=\"/img/emoticons/happy.png\" alt=\":happy:\" title=\":happy:\">">>;
getbbsmile(21) -> <<"<img src=\"/img/emoticons/kissing.png\" alt=\":kissing:\" title=\":kissing:\">">>;
getbbsmile(22) -> <<"<img src=\"/img/emoticons/ninja.png\" alt=\":ninja:\" title=\":ninja:\">">>;
getbbsmile(23) -> <<"<img src=\"/img/emoticons/pinch.png\" alt=\":pinch:\" title=\":pinch:\">">>;
getbbsmile(24) -> <<"<img src=\"/img/emoticons/pouty.png\" alt=\":pouty:\" title=\":pouty:\">">>;
getbbsmile(25) -> <<"<img src=\"/img/emoticons/sick.png\" alt=\":sick:\" title=\":sick:\">">>;
getbbsmile(26) -> <<"<img src=\"/img/emoticons/sideways.png\" alt=\":sideways:\" title=\":sideways:\">">>;
getbbsmile(27) -> <<"<img src=\"/img/emoticons/silly.png\" alt=\":silly:\" title=\":silly:\">">>;
getbbsmile(28) -> <<"<img src=\"/img/emoticons/sleeping.png\" alt=\":sleeping:\" title=\":sleeping:\">">>;
getbbsmile(29) -> <<"<img src=\"/img/emoticons/unsure.png\" alt=\":unsure:\" title=\":unsure:\">">>;
getbbsmile(30) -> <<"<img src=\"/img/emoticons/w00t.png\" alt=\":woot:\" title=\":woot:\">">>;
getbbsmile(31) -> <<"<img src=\"/img/emoticons/wassat.png\" alt=\":wassat:\" title=\":wassat:\">">>;
getbbsmile(_) -> <<"<img src=\"/img/emoticons/smile.png\" alt=\":)\" title=\":)\">">>.




