-module(cart).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], [], []),
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  
  Title = <<"Cart | Eshop">>,
  CartWindowHTML = <<"No items">>,
  
  #dtl{file="cart",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, <<"Catalog">>},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, <<"Eshop">>},
      {mainbutton, <<"Main">>},
      {cartbutton, <<"Cart">>},
      {cartpagetitle, <<"Your cart">>},
      {cartpagegoods, CartWindowHTML},
      {cartpageordernow, <<"Order now">>},
      {footercopybrandyear, <<"Eshop &copy; 2018">>} ]}.


event(init) ->
  ok;


event({client,{new_order,Name,Phone,Email,Text,GoodsInfo}})
when erlang:is_binary(Name), Name =/= <<"">>, erlang:is_binary(Phone), Phone =/= <<"">>, erlang:is_binary(Email), Email =/= <<"">>, erlang:is_binary(Text), erlang:is_binary(GoodsInfo) ->
  
  Name2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Name))),
  Phone2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Phone))),
  Email2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Email))),
  Text2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Text))),
  GoodsInfo2 = hm:bin2hstorepairs(string:split(GoodsInfo,",",all),[]),
  
  % prepare message for tg bot
  GoodsInfo6 = hg:prepare_ordermessage_for_tg(Name2, Phone2, Email2, Text2, GoodsInfo2),
  
  case pq:add_new_order(Name2,Phone2,Email2,Text,GoodsInfo2) of
    1 ->
      wf:wire("alert('success !');del_allitemslocalStorage();items2cart();window.sendord_wait=false;"),
      hm:update_goods_rates(GoodsInfo2),
      hm:telegram_send_message(GoodsInfo6);
    _ ->
      wf:wire("alert('database error !');window.sendord_wait=false;")
  end;


event(_) -> [].

