-module(not_found).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() ->
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], Lang, [], []),
  
  wf:state(status,404),
  
  Title = <<"Eshop">>,
  
  #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}.


event(init) ->
  ok;


event(_) -> [].
