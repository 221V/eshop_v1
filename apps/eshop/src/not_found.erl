-module(not_found).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() ->
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], [], []),
  
  wf:state(status,404),
  
  Title = <<"Eshop">>,
  
  #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, <<"Catalog">>},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, <<"Eshop">>},
      {mainbutton, <<"Main">>},
      {cartbutton, <<"Cart">>},
      {footercopybrandyear, <<"Eshop &copy; 2018">>} ]}.


event(init) ->
  ok;


event(_) -> [].
