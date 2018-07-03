-module(main).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], Lang, [], []),
  
  Title = [ tr:tr(Lang, main, <<"main">>), <<" | ">>, tr:tr(<<"">>, project_name, <<"">>) ],
  CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
  SortSelectHTML = hg:generate_sortselect_opts(Lang),
  Offset = 0,
  Limit = 30,
  PageGoodsData = pq:get_goods_main_by_rate(Limit, Offset),
  PageGoodsHTML = hg:generate_main_goodscards(PageGoodsData, Lang ,[]),
  
  #dtl{file="main",app=eshop,bindings=[ {pagetitle, unicode:characters_to_binary(Title,utf8)},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {carttitle, tr:tr(Lang, main, <<"cart_title">>)},
      {cartwindow, CartWindowHTML},
      {cartformname, tr:tr(Lang, cart, <<"your_name">>)},
      {cartformemail, tr:tr(Lang, cart, <<"your_email">>)},
      {cartformphone, tr:tr(Lang, cart, <<"your_phone">>)},
      {cartformcomment, tr:tr(Lang, cart, <<"your_comment">>)},
      {cartclose, tr:tr(Lang, main, <<"close">>)},
      {cartordernow, tr:tr(Lang, main, <<"order_now">>)},
      {sortselectoptions, SortSelectHTML},
      {pagegoods, PageGoodsHTML},
      {loadnmoregoods, tr:tr(Lang, main, <<"load_more_goods">>)},
      {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}.


event(init) ->
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  [{Count}] = pq:get_allactive_goods_count(),
  % Limit first load = 30
  if Count =< 30 ->
      wf:wire("qi('loadmorebl').style.display='none';found_and_select(qi('goodssorting'),1);");
    true ->
      % Count > 30
      Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
      Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
      More_Text = [ Load1, <<" [30] ">>, Load2 ],
      
      JS_NoItems = tr:tr(Lang, cart, <<"no_items">>),
      JS_Price = tr:tr(Lang, js, <<"price">>),
      JS_Total = tr:tr(Lang, js, <<"total">>),
      JS_Total_Price = tr:tr(Lang, js, <<"total_price">>),
      JS_Fill_Form = tr:tr(Lang, js, <<"fill_form">>),
      
      wf:wire(wf:f("window.i18n=[];window.i18n.push('~s');"
        "window.i18n.push('~s');window.i18n.push('~s');"
        "window.i18n.push('~s');window.i18n.push('~s');",[unicode:characters_to_binary(JS_NoItems,utf8), unicode:characters_to_binary(JS_Price,utf8), unicode:characters_to_binary(JS_Total,utf8), unicode:characters_to_binary(JS_Total_Price,utf8), unicode:characters_to_binary(JS_Fill_Form,utf8)])),
      
      wf:wire(wf:f("found_and_select(qi('goodssorting'),1);window.goodsallcount=~s;window.goodsloaded=~s;window.sort_type=~s;"
                   "qi('loadmorebtn').innerText='~s';bind_load_more();items2cart();",[erlang:integer_to_binary(Count), <<"30">>, <<"1">>, unicode:characters_to_binary(More_Text,utf8)]))
  end;


event({client,{new_order,Name,Phone,Email,Text,GoodsInfo}})
when erlang:is_binary(Name), Name =/= <<"">>, erlang:is_binary(Phone), Phone =/= <<"">>, erlang:is_binary(Email), Email =/= <<"">>, erlang:is_binary(Text), erlang:is_binary(GoodsInfo) ->
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Name2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Name))),
  Phone2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Phone))),
  Email2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Email))),
  Text2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Text))),
  GoodsInfo2 = hm:bin2hstorepairs(string:split(GoodsInfo,",",all),[]),
  
  % prepare message for tg bot
  GoodsInfo6 = hg:prepare_ordermessage_for_tg(Name2, Phone2, Email2, Text2, GoodsInfo2),
  
  case pq:add_new_order(Name2,Phone2,Email2,Text,GoodsInfo2) of
    1 ->
      Success = tr:tr(Lang, main, <<"success">>),
      wf:wire(wf:f("alert('~s !');del_allitemslocalStorage();items2cart();window.sendord_wait=false;",[Success])),
      hm:update_goods_rates(GoodsInfo2),
      hm:telegram_send_message(GoodsInfo6);
    _ ->
      wf:wire("alert('database error !');window.sendord_wait=false;")
  end;


%event({client,{load_first,Cat_Id,Sort_Type}})
event({client,{load_first,0,Sort_Type}})
when erlang:is_integer(Sort_Type) ->
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Limit = 30,
  Offset = 0,
  % Sort_Type = 1 - by rating, 2 - cheapest first, 3 - most expensive first
  Goods_Data = case Sort_Type of
    1 -> pq:get_goods_main_by_rate(Limit, Offset);
    2 -> pq:get_goods_main_by_lowprice(Limit, Offset);
    %3 -> 
    _ -> pq:get_goods_main_by_hightprice(Limit, Offset)
  end,
  
  case Goods_Data of
    [] ->
      Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
      wf:wire(wf:f("var cont = document.querySelector('.card-columns');cont.innerHTML = `~s`;",[unicode:characters_to_binary(Page_Goods,utf8)])),
      
      wf:wire(wf:f("qi('loadmorebtn').style.display='none';"
                   "window.goodsloaded=~s;window.load_first_wait=false;",[<<"30">>]));
    [{_,_,_,_,_,_,_}|_] ->
      
      Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
      wf:wire(wf:f("var cont = document.querySelector('.card-columns');cont.innerHTML = `~s`;",[unicode:characters_to_binary(Page_Goods,utf8)])),
      
      Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
      Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
      Load_More = [ Load1, <<" [30] ">>, Load2 ],
      
      wf:wire(wf:f("qi('loadmorebtn').innerText='~s';qi('loadmorebtn').style.display='block';"
                   "window.goodsloaded=~s;window.load_first_wait=false;",[unicode:characters_to_binary(Load_More,utf8), <<"30">>]));
    _ ->
      wf:wire("qi('loadmorebtn').style.display='block';window.load_first_wait=false;alert('database error !');")
  end;


%event({client,{load_more,All_Count,Loaded,Cat_Id,Sort_Type}})
event({client,{load_more,All_Count,Loaded,0,Sort_Type}})
when erlang:is_integer(Loaded), Loaded > 0, erlang:is_integer(All_Count), All_Count > 0, erlang:is_integer(Sort_Type) ->
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Limit = 30,
  % Sort_Type = 1 - by rating, 2 - cheapest first, 3 - most expensive first
  Goods_Data = case Sort_Type of
    1 -> pq:get_goods_main_by_rate(Limit, Loaded);
    2 -> pq:get_goods_main_by_lowprice(Limit, Loaded);
    %3 -> 
    _ -> pq:get_goods_main_by_hightprice(Limit, Loaded)
  end,
  
  case Goods_Data of
    [] ->
      ok;
    [{_,_,_,_,_,_,_}|_] ->
      
      Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
      wf:wire(wf:f("var cont = document.querySelector('.card-columns');cont.insertAdjacentHTML('beforeend', `~s`);",[unicode:characters_to_binary(Page_Goods,utf8)])),
      
      Offset2 = Loaded + Limit,
      Offset3 = Offset2 + Limit,
      if Offset2 >= All_Count ->
          ok;
        Offset2 < All_Count, Offset3 >= All_Count ->
          
          Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
          Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
          Load_More = [ Load1, <<" [">>, erlang:integer_to_binary(All_Count - Offset2), <<"] ">>, Load2 ],
          
          wf:wire(wf:f("qi('loadmorebtn').innerText='~s';qi('loadmorebtn').style.display='block';"
                       "window.goodsloaded=~s;window.load_more_wait=false;",[unicode:characters_to_binary(Load_More,utf8), erlang:integer_to_binary(Offset2)]));
        %Offset2 < All_Count, Offset3 < All_Count ->
        true ->
          Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
          Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
          Load_More = [ Load1, <<" [30] ">>, Load2 ],
          wf:wire(wf:f("qi('loadmorebtn').innerText='~s';qi('loadmorebtn').style.display='block';"
                       "window.goodsloaded=~s;window.load_more_wait=false;",[unicode:characters_to_binary(Load_More,utf8), erlang:integer_to_binary(Offset2)]))
      end;
    _ ->
      wf:wire("qi('loadmorebtn').style.display='block';window.load_more_wait=false;alert('database error !');")
  end;


event(_) -> [].

