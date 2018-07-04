-module(cart).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], Lang, [], []),
  
  Title = [ tr:tr(Lang, main, <<"cart">>), <<" | ">>, tr:tr(<<"">>, project_name, <<"">>) ],
  CartWindowHTML = tr:tr(Lang, cart, <<"no_items">>),
  
  #dtl{file="cart",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {cartpagetitle, tr:tr(Lang, main, <<"cart_title">>)},
      {cartformname, tr:tr(Lang, cart, <<"your_name">>)},
      {cartformemail, tr:tr(Lang, cart, <<"your_email">>)},
      {cartformphone, tr:tr(Lang, cart, <<"your_phone">>)},
      {cartformcomment, tr:tr(Lang, cart, <<"your_comment">>)},
      {cartpagegoods, CartWindowHTML},
      {cartpageordernow, tr:tr(Lang, main, <<"order_now">>)},
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
    "items2cart();",[unicode:characters_to_binary(JS_NoItems,utf8), unicode:characters_to_binary(JS_Price,utf8), unicode:characters_to_binary(JS_Total,utf8), unicode:characters_to_binary(JS_Total_Price,utf8), unicode:characters_to_binary(JS_Fill_Form,utf8), unicode:characters_to_binary(JS_Currency,utf8)]));


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


event(_) -> [].

