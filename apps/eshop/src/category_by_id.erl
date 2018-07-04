-module(category_by_id).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  %#dtl{file="null",app=eshop,bindings=[]}.
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], Lang, [], []),
  
  Cat_Id = wf:qp(<<"id">>),
  Cat_Id_Valid = erlang:is_binary(Cat_Id) andalso hm:is_valid_binnumber(Cat_Id),
  
  case Cat_Id_Valid of
    true ->
      Cat_Id2 = erlang:binary_to_integer(Cat_Id),
      
      Cat_Data = pq:get_category_by_id(Cat_Id2),
      
      case Cat_Data of
        %[{Category_Name, Parent, Ordering}] ->
        [{Category_Name, _, _}] ->
          % category found
          
          Cat_Childs_Data = pq:get_category_childs_by_id(Cat_Id2),
          case Cat_Childs_Data of
            [{_,_}|_] ->
              % founds childs categories
              
              Load_More = <<"">>,
              SortSelectHTML = <<"">>,
              
              Page_Goods = hg:generate_cat_childsrows(Cat_Childs_Data, Lang, []),
              
              CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
              
              Category_Name2 = tr_catalog:tr(Lang,Category_Name),
              PageTitle = [Category_Name2, <<" | ">>, tr:tr(<<"">>, project_name, <<"">>)],
              Active_Category = [ tr:tr(Lang, category, <<"active_category">>), <<": ">>, Category_Name2 ],
              
              ?MODULE:helper_category_found(Lang, PageTitle, Html_Categories, CartWindowHTML, Active_Category, SortSelectHTML, Page_Goods, Load_More);
            [] ->
              % not found childs categories
              % search goods for category -- show goods
              Offset = 0,
              Limit = 30,
              Goods_Data = pq:get_goods_category_by_rate(Cat_Id2, Limit, Offset),
              
              case Goods_Data of
                [] ->
                  % not found childs categories
                  % and not found goods
                  Load_More = <<"">>,
                  SortSelectHTML = <<"">>,
                  Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
                  CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
                  Category_Name2 = tr_catalog:tr(Lang,Category_Name),
                  PageTitle = [Category_Name2, <<" | ">>, tr:tr(<<"">>, project_name, <<"">>)],
                  Active_Category = [ tr:tr(Lang, category, <<"active_category">>), <<": ">>, Category_Name ],
                  ?MODULE:helper_category_found(Lang, PageTitle, Html_Categories, CartWindowHTML, Active_Category, SortSelectHTML, Page_Goods, Load_More);
                [{_,_,_,_,_,_,_}|_] ->
                  % found goods
                  
                  Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
                  Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
                  Load_More = [ Load1, <<" [30] ">>, Load2 ],
                  
                  SortSelectHTML = hg:generate_sortselect_opts(Lang),
                  Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
                  CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
                  Category_Name2 = tr_catalog:tr(Lang,Category_Name),
                  PageTitle = [Category_Name2, <<" | ">>, tr:tr(<<"">>, project_name, <<"">>)],
                  Active_Category = [ tr:tr(Lang, category, <<"active_category">>), <<": ">>, Category_Name ],
                  ?MODULE:helper_category_found(Lang, PageTitle, Html_Categories, CartWindowHTML, Active_Category, SortSelectHTML, Page_Goods, Load_More);
                _ ->
                  % db err
                  Title = <<"Database Error">>,
                  ?MODULE:helper_not_found(Lang, Title, Html_Categories)
              end;
            _ ->
              SortSelectHTML = <<"">>,
              Load_More = <<"">>,
              Page_Goods =  <<"<span id=\"no_goods_here\">database error !</span>">>,
              CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
              Category_Name2 = tr_catalog:tr(Lang,Category_Name),
              PageTitle = [Category_Name2, <<" | ">>, tr:tr(<<"">>, project_name, <<"">>)],
              Active_Category = <<"">>,
              
              ?MODULE:helper_category_found(Lang, PageTitle, Html_Categories, CartWindowHTML, Active_Category, SortSelectHTML, Page_Goods, Load_More)
          end;
        [] ->
          % not found
          Title = tr:tr(<<"">>, project_name, <<"">>),
          ?MODULE:helper_not_found(Lang, Title, Html_Categories);
        _ ->
          % db err
          Title = <<"Database Error">>,
          ?MODULE:helper_not_found(Lang, Title, Html_Categories)
      end;
    _ ->
      % invalid category id
      Title = tr:tr(<<"">>, project_name, <<"">>),
      ?MODULE:helper_not_found(Lang, Title, Html_Categories)
  end.


helper_not_found(Lang, Title, Html_Categories) ->
  #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}.


helper_category_found(Lang, PageTitle, Html_Categories, CartWindowHTML, Active_Category, SortSelectHTML, Page_Goods, Load_More) ->
  #dtl{file="category",app=eshop,bindings=[ {pagetitle, unicode:characters_to_binary(PageTitle,utf8)},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {carttitle, tr:tr(Lang, main, <<"cart_title">>)},
      {cartwindow, unicode:characters_to_binary(CartWindowHTML,utf8)},
      {cartclose, tr:tr(Lang, main, <<"close">>)},
      {cartordernow, tr:tr(Lang, main, <<"order_now">>)},
      {active_category, unicode:characters_to_binary(Active_Category,utf8)},
      {sortselectoptions, unicode:characters_to_binary(SortSelectHTML,utf8)},
      {pagegoods, unicode:characters_to_binary(Page_Goods,utf8)},
      {loadnmoregoods, Load_More},
      {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}.


event(init) ->
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  JS_NoItems = tr:tr(Lang, cart, <<"no_items">>), % i18n[0]
  JS_Price = tr:tr(Lang, js, <<"price">>), % i18n[1]
  JS_Total = tr:tr(Lang, js, <<"total">>), % i18n[2]
  JS_Total_Price = tr:tr(Lang, js, <<"total_price">>), % i18n[3]
  JS_Fill_Form = tr:tr(Lang, js, <<"fill_form">>), % i18n[4]
  
  JS_Currency = wf:config(n2o, currency, "usd"), % settings[0]
  
  wf:wire(wf:f("window.i18n=[];window.i18n.push('~s');"
    "window.i18n.push('~s');window.i18n.push('~s');"
    "window.i18n.push('~s');window.i18n.push('~s');"
    "window.settings=[];window.settings.push('~s');"
    "items2cart();",[unicode:characters_to_binary(JS_NoItems,utf8), unicode:characters_to_binary(JS_Price,utf8), unicode:characters_to_binary(JS_Total,utf8), unicode:characters_to_binary(JS_Total_Price,utf8), unicode:characters_to_binary(JS_Fill_Form,utf8), unicode:characters_to_binary(JS_Currency,utf8)])),
  
  Cat_Id = wf:qp(<<"id">>),
  Cat_Id_Valid = erlang:is_binary(Cat_Id) andalso hm:is_valid_binnumber(Cat_Id),
  case Cat_Id_Valid of
    true ->
      Cat_Id2 = erlang:binary_to_integer(Cat_Id),
      [{Count}] = pq:get_catactive_goods_count(Cat_Id2),
      % Limit first load = 30
      if Count =< 30 ->
          wf:wire("qi('loadmorebl').style.display='none';found_and_select(qi('goodssorting'),1);");
        true ->
          % Count > 30
          
          Load1 = tr:tr(Lang, main, <<"load_more_goods1">>),
          Load2 = tr:tr(Lang, main, <<"load_more_goods2">>),
          More_Text = [ Load1, <<" [30] ">>, Load2 ],
      
          wf:wire(wf:f("found_and_select(qi('goodssorting'),1);window.goodsallcount=~s;window.goodsloaded=~s;window.cat_id=~s;window.sort_type=~s;"
                       "qi('loadmorebtn').innerText='~s';bind_load_more();",[erlang:integer_to_binary(Count), <<"30">>, Cat_Id, <<"1">>, unicode:characters_to_binary(More_Text,utf8)]))
      end;
    _ ->
      err
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


event({client,{load_first,Cat_Id,Sort_Type}})
when erlang:is_integer(Cat_Id), erlang:is_integer(Sort_Type) ->
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Limit = 30,
  Offset = 0,
  % Sort_Type = 1 - by rating, 2 - cheapest first, 3 - most expensive first
  Goods_Data = case Sort_Type of
    1 -> pq:get_goods_category_by_rate(Cat_Id, Limit, Offset);
    2 -> pq:get_goods_category_by_lowprice(Cat_Id, Limit, Offset);
    %3 -> 
    _ -> pq:get_goods_category_by_hightprice(Cat_Id, Limit, Offset)
  end,
  case Goods_Data of
    [] ->
      Page_Goods = hg:generate_main_goodscards(Goods_Data, Lang, []),
      wf:wire(wf:f("var cont = document.querySelector('.card-columns');cont.innerHTML = `~s`;",[unicode:characters_to_binary(Page_Goods,utf8)])),
      
      wf:wire(wf:f("qi('loadmorebtn').style.display='none';"
                   "window.goodsloaded=~s;window.load_first_wait=false;",[ <<"30">>]));
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


event({client,{load_more,All_Count,Loaded,Cat_Id,Sort_Type}})
when erlang:is_integer(Loaded), Loaded > 0, erlang:is_integer(All_Count), All_Count > 0, erlang:is_integer(Cat_Id), erlang:is_integer(Sort_Type) ->
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Limit = 30,
  % Sort_Type = 1 - by rating, 2 - cheapest first, 3 - most expensive first
  Goods_Data = case Sort_Type of
    1 -> pq:get_goods_category_by_rate(Cat_Id, Limit, Loaded);
    2 -> pq:get_goods_category_by_lowprice(Cat_Id, Limit, Loaded);
    %3 -> 
    _ -> pq:get_goods_category_by_hightprice(Cat_Id, Limit, Loaded)
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


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].





