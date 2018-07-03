-module(good_by_id).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  %#dtl{file="null",app=eshop,bindings=[]}.
  
  %Lang = hm:get_language(<<"lang">>,?REQ),
  Lang = <<"uk">>,
  
  Data_Categories = pq:get_categories(),
  Html_Categories = hg:generate_cat_tree(Data_Categories, [], Lang, [], []),
  
  Good_Id = wf:qp(<<"id">>),
  Good_Id_Valid = erlang:is_binary(Good_Id) andalso hm:is_valid_binnumber(Good_Id),
  
  case Good_Id_Valid of
    true ->
      
      Good_Data = pq:get_goods_adminka_by_id(erlang:binary_to_integer(Good_Id)),
      
      case Good_Data of
        %[{Id, Title, Img_Title, BB_preview_text, Html_preview_text, BB_full_text, Html_full_text, Category_Id, Bought_Count, Price, Available_Status, Status}] ->
        [{Id, Title, _, _, _, _, Html_full_text, Category_Id, _, Price, Available_Status, 1}] ->
          % found and show
          
          [{Category_Name,_,_}] = pq:get_category_by_id(Category_Id),
          Imgs_Data = pq:get_active_images_by_gid(Id),
          Imgs_HTML = hg:generate_goodpage_gidallimages_rows(Imgs_Data, Imgs_Data, []),
          
          PageTitle = [Title, <<" | ">>, tr:tr(<<"">>, project_name, <<"">>)],
          Category_Name2 = tr_catalog:tr(Lang,Category_Name),
          GoodCategoryHtml = [ <<"<a href=\"/category/?id=">>, erlang:integer_to_binary(Category_Id), <<"\" target=\"_blank\">">>, Category_Name2, <<"</a>">> ],
          Add2Cart = tr:tr(Lang, main_goods, <<"add_to_cart">>),
          
          #dtl{file="good",app=eshop,bindings=[ {pagetitle, unicode:characters_to_binary(PageTitle,utf8)},
          {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
          {goodpagecattext, tr:tr(Lang, goods, <<"category_text">>)},
          {goodpagecategory, unicode:characters_to_binary(GoodCategoryHtml,utf8)},
          {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
          {brandname, tr:tr(Lang, main, <<"brand">>)},
          {mainbutton, tr:tr(Lang, main, <<"main">>)},
          {cartbutton, tr:tr(Lang, main, <<"cart">>)},
          {goodpagetitle, unicode:characters_to_binary(Title,utf8)},
          {goodpageimgs, unicode:characters_to_binary(Imgs_HTML,utf8)},
          {goodpageinfo, Html_full_text},
          {goodpageid, erlang:integer_to_binary(Id)},
          {goodpageprice, erlang:integer_to_binary(Price)},
          {goodpageadd2cart, Add2Cart},
          {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]};
        [{_, _, _, _, _, _, _, _, _, _, _, _}] ->
          % found and status = not show
          Title = tr:tr(<<"">>, project_name, <<"">>),
          
          #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
          {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
          {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
          {brandname, tr:tr(Lang, main, <<"brand">>)},
          {mainbutton, tr:tr(Lang, main, <<"main">>)},
          {cartbutton, tr:tr(Lang, main, <<"cart">>)},
          {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]};
        [] ->
          % not found
          Title = tr:tr(<<"">>, project_name, <<"">>),
          
          #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
          {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
          {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
          {brandname, tr:tr(Lang, main, <<"brand">>)},
          {mainbutton, tr:tr(Lang, main, <<"main">>)},
          {cartbutton, tr:tr(Lang, main, <<"cart">>)},
          {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]};
        _ ->
          % db err
          Title = <<"Database Error">>,
          
          #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
          {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
          {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
          {brandname, tr:tr(Lang, main, <<"brand">>)},
          {mainbutton, tr:tr(Lang, main, <<"main">>)},
          {cartbutton, tr:tr(Lang, main, <<"cart">>)},
          {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}
      end;
    _ ->
      
      Title = tr:tr(<<"">>, project_name, <<"">>),
      
      #dtl{file="not_found",app=eshop,bindings=[ {pagetitle, Title},
      {catalogtitle, tr:tr(Lang, main, <<"catalog">>)},
      {dropdowncatalog, unicode:characters_to_binary(Html_Categories, utf8)},
      {brandname, tr:tr(Lang, main, <<"brand">>)},
      {mainbutton, tr:tr(Lang, main, <<"main">>)},
      {cartbutton, tr:tr(Lang, main, <<"cart">>)},
      {footercopybrandyear, unicode:characters_to_binary([ tr:tr(Lang, main, <<"brand">>), <<" &copy; 2018">> ],utf8)} ]}
  end.


event(init) ->
  ok;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

