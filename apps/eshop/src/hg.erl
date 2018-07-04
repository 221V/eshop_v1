-module(hg).
-compile([export_all, nowarn_export_all]).

%html generate module

% generate_cat_tree(All_Data, [], Lang, [], []) | generate_cat_tree(NonRoot_Data, Root_Data, Lang, Html_Acc, Drop_Id)
% generate_admin_cat_list(All_Data, [], [], <<"">>) | generate_admin_cat_list(NonRoot_Data, Root_Data, Html_Acc, Dot_Id)
% generate_admin_cat_rows(All_Data, [], Lang, [], <<"">>) | generate_admin_cat_rows(NonRoot_Data, Root_Data, Lang, Html_Acc, Dot_Id)
% generate_cat_childsrows(Data,Lang,Acc)
% generate_admin_addgoodform(Cats_HTML)
% generate_admin_editgoodform({Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}, Cats_HTML, Acc)
% generate_admin_edithtmlgoodform({Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}, Cats_HTML, Acc)
% generate_admin_loginform()
% generate_admin_info()
% generate_admin_actionlist()
% generate_admin_draguploadimg()
% generate_admin_makepreviewimg()
% generate_admin_gidimg_form()
% generate_admin_gidallimages_rows(Images_Data, Acc)
% generate_goodpage_gidallimages_rows(Images_Data, Images_Data_0, Acc)
% generate_admin_goods_rows(Goods_Data,Acc)
% generate_admin_orders_rows(Orders_Data,Acc)
% generate_simple_pagination(Active_Page, true||false)
% generate_sortselect_opts(Lang)
% generate_main_goodscards(PageGoodsData, Lang, Acc)
% 


%generate_cat_tree(All_Data, [], Lang, [], [])
%generate_cat_tree(NonRoot_Data, Root_Data, Lang, Html_Acc, Drop_Id)
generate_cat_tree(All_Data, [], Lang, [], []) ->
  %% begin work here -- create root-data-list and nonroot-data-list
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,0,_,_}) -> true; (_) -> false end,
  F2 = fun({_,_,0,_,_}) -> false; (_) -> true end,
  
  Root_Data = lists:filter(F1,All_Data),
  NonRoot_Data = lists:filter(F2,All_Data),
  %% Drop_Id starts from 2
  ?MODULE:generate_cat_tree(NonRoot_Data, Root_Data, Lang, [], 2);
generate_cat_tree(_, [], _, Html_Acc, _) ->
  %% exit here
  lists:reverse(Html_Acc);
%generate_cat_tree(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Lang, Html_Acc, Drop_Id)
generate_cat_tree(NonRoot_Data, [{Id,Name,_,0,_}|T], Lang, Html_Acc, Drop_Id) ->
  ?MODULE:generate_cat_tree(NonRoot_Data, T, Lang, Html_Acc, Drop_Id);
generate_cat_tree(NonRoot_Data, [{Id,Name,_,1,_}|T], Lang, Html_Acc, Drop_Id) ->
  % work for html here
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  case ByParent1 of
    [] ->
      %% no dropdown
      Name2 = tr_catalog:tr(Lang,Name),
      Z = [ <<"<li role=\"presentation\"><a role=\"menuitem\" href=\"/category/?id=">>, Id3, <<"\">">>, Name2, <<"</a></li>">> ],
      ?MODULE:generate_cat_tree(NonRoot_Data, T, Lang, [Z|Html_Acc], Drop_Id);
    _ ->
      %% dropdown here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      
      Name2 = tr_catalog:tr(Lang,Name),
      OpenPart = [ <<"<li role=\"presentation\" class=\"dropdown\"><a role=\"menuitem\" href=\"/category/?id=">>, Id3, <<"\" onclick=\"return false;\" data-toggle=\"dropdown\">">>, Name2, <<" <span class=\"caret\"></span></a><ul class=\"dropdown-menu right\" role=\"menu\" aria-labelledby=\"drop">>, erlang:integer_to_binary(Drop_Id), <<"\">">> ],
      
      {R1,Drop_Id2} = ?MODULE:generate_cat_tree_helper1(NonRoot_Data2, ByParent2, Lang, [], Drop_Id + 1),
      Z = [ OpenPart, R1, <<"</ul></li>">> ],
      ?MODULE:generate_cat_tree(NonRoot_Data2, T, Lang, [Z|Html_Acc], Drop_Id2)
  end.

%% helper1
%generate_cat_tree_helper1(NonRoot_Data, Root_Data, Lang, Html_Acc, Drop_Id)
generate_cat_tree_helper1(_, [], _, Html_Acc, Drop_Id) ->
  {lists:reverse(Html_Acc), Drop_Id};
%generate_cat_tree_helper1(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Lang, Html_Acc, Drop_Id)
generate_cat_tree_helper1(NonRoot_Data, [{Id,Name,_,0,_}|T], Lang, Html_Acc, Drop_Id) ->
  ?MODULE:generate_cat_tree_helper1(NonRoot_Data, T, Lang, Html_Acc, Drop_Id);
generate_cat_tree_helper1(NonRoot_Data, [{Id,Name,_,1,_}|T], Lang, Html_Acc, Drop_Id) ->
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  case ByParent1 of
    [] ->
      %% no dropdown
      Name2 = tr_catalog:tr(Lang,Name),
      Z = [ <<"<li role=\"presentation\"><a role=\"menuitem\" href=\"/category/?id=">>, Id3, <<"\">">>, Name2, <<"</a></li>">> ],
      ?MODULE:generate_cat_tree_helper1(NonRoot_Data, T, Lang, [Z|Html_Acc], Drop_Id);
    _ ->
      %% dropdown here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      
      Name2 = tr_catalog:tr(Lang,Name),
      OpenPart = [ <<"<li role=\"presentation\" class=\"dropdown\"><a role=\"menuitem\" href=\"/category/?id=">>, Id3, <<"\" onclick=\"return false;\" data-toggle=\"dropdown\">">>, Name2, <<" <span class=\"caret\"></span></a><ul class=\"dropdown-menu right\" role=\"menu\" aria-labelledby=\"drop">>, erlang:integer_to_binary(Drop_Id), <<"\">">> ],
      
      {R1,Drop_Id2} = ?MODULE:generate_cat_tree_helper1(NonRoot_Data2, ByParent2, Lang, [], Drop_Id + 1),
      Z = [ OpenPart, R1, <<"</ul></li>">> ],
      ?MODULE:generate_cat_tree_helper1(NonRoot_Data2, T, Lang, [Z|Html_Acc], Drop_Id2)
  end.


%generate_admin_cat_list(All_Data, [], [], <<"">>)
%generate_admin_cat_list(NonRoot_Data, Root_Data, Html_Acc, Dot_Id)
generate_admin_cat_list(All_Data, [], [], <<"">>) ->
  %% begin work here -- create root-data-list and nonroot-data-list
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,0,_,_}) -> true; (_) -> false end,
  F2 = fun({_,_,0,_,_}) -> false; (_) -> true end,
  
  Root_Data = lists:filter(F1,All_Data),
  NonRoot_Data = lists:filter(F2,All_Data),
  Html_Acc = <<"<select id=\"cat_id\">">>,
  %% Dot_Id starts from 2 dots
  ?MODULE:generate_admin_cat_list(NonRoot_Data, Root_Data, [Html_Acc|[]], <<"..">>);
generate_admin_cat_list(_, [], Html_Acc, _) ->
  %% exit here
  lists:reverse([<<"</select>">>|Html_Acc]);
%generate_admin_cat_list(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Html_Acc, Dot_Id)
generate_admin_cat_list(NonRoot_Data, [{Id,Name,_,Status,_}|T], Html_Acc, Dot_Id) ->
  % work for html here
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  Status2 = case Status of
    0 -> <<" [hide] ">>;
    %1 -> <<" [show] ">>
    _ -> <<" [show] ">>
  end,
  case ByParent1 of
    [] ->
      %% no childs
      Z = [ <<"<option value=\"">>, Id3, <<"\">">>, Name, Status2, <<"</option>">> ],
      ?MODULE:generate_admin_cat_list(NonRoot_Data, T, [Z|Html_Acc], Dot_Id);
    _ ->
      %% childs here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      
      R1 = [ <<"<option value=\"">>, Id3, <<"\">">>, Name, Status2, <<"</option>">> ],
      
      {R2,_} = ?MODULE:generate_admin_cat_list_helper1(NonRoot_Data2, ByParent2, [], Dot_Id),
      Z = [ R1, R2 ],
      ?MODULE:generate_admin_cat_list(NonRoot_Data2, T, [Z|Html_Acc], Dot_Id)
  end.

%% helper1
%generate_admin_cat_list_helper1(NonRoot_Data, Root_Data, Html_Acc, Dot_Id)
generate_admin_cat_list_helper1(_, [], Html_Acc, Dot_Id) ->
  {lists:reverse(Html_Acc), Dot_Id};
%generate_admin_cat_list_helper1(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Html_Acc, Dot_Id)
generate_admin_cat_list_helper1(NonRoot_Data, [{Id,Name,_,Status,_}|T], Html_Acc, Dot_Id) ->
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  Status2 = case Status of
    0 -> <<" [hide] ">>;
    %1 -> <<" [show] ">>
    _ -> <<" [show] ">>
  end,
  case ByParent1 of
    [] ->
      %% no childs
      Z = [ <<"<option value=\"">>, Id3, <<"\">">>, Dot_Id, <<" ">>, Name, Status2, <<"</option>">> ],
      ?MODULE:generate_admin_cat_list_helper1(NonRoot_Data, T, [Z|Html_Acc], Dot_Id);
    _ ->
      %% childs here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      Dot_Id2 = <<"..", Dot_Id/binary>>,
      
      R1 = [ <<"<option value=\"">>, Id3, <<"\">">>, Dot_Id, <<" ">>, Name, Status2, <<"</option>">> ],
      
      {R2,Dot_Id3} = ?MODULE:generate_admin_cat_list_helper1(NonRoot_Data2, ByParent2, [], Dot_Id2),
      Z = [ R1, R2 ],
      ?MODULE:generate_admin_cat_list_helper1(NonRoot_Data2, T, [Z|Html_Acc], Dot_Id3)
  end.


%generate_admin_cat_rows(All_Data, [], Lang, [], <<"">>)
%generate_admin_cat_rows(NonRoot_Data, Root_Data, Lang, Html_Acc, Dot_Id)
generate_admin_cat_rows(All_Data, [], Lang, [], <<"">>) ->
  %% begin work here -- create root-data-list and nonroot-data-list
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,0,_,_}) -> true; (_) -> false end,
  F2 = fun({_,_,0,_,_}) -> false; (_) -> true end,
  
  Root_Data = lists:filter(F1,All_Data),
  NonRoot_Data = lists:filter(F2,All_Data),
  Html_Acc = [ <<"<p><label><span>New category</span><br><span>category name</span><br><input id=\"new_category_name\" type=\"text\"></label><br><button onclick=\"new_category(this);\">Add category</button></p><hr class=\"style16\">">> ],
  %% Dot_Id starts from 2 dots
  ?MODULE:generate_admin_cat_rows(NonRoot_Data, Root_Data, Lang, [Html_Acc|[]], <<"..">>);
generate_admin_cat_rows(_, [], _, Html_Acc, _) ->
  %% exit here
  lists:reverse(Html_Acc);
%generate_admin_cat_rows(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Lang, Html_Acc, Dot_Id)
generate_admin_cat_rows(NonRoot_Data, [{Id,Name,_,Status,Ordering}|T], Lang, Html_Acc, Dot_Id) ->
  % work for html here
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  case ByParent1 of
    [] ->
      %% no childs
      Z = ?MODULE:generate_admin_cat_rows_helper2(Id3,Name,Lang,Status,Ordering),
      ?MODULE:generate_admin_cat_rows(NonRoot_Data, T, Lang, [Z|Html_Acc], Dot_Id);
    _ ->
      %% childs here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      
      R1 = ?MODULE:generate_admin_cat_rows_helper2(Id3,Name,Lang,Status,Ordering),
      
      {R2,_} = ?MODULE:generate_admin_cat_rows_helper1(NonRoot_Data2, ByParent2, Lang, [], Dot_Id),
      Z = [ R1, R2 ],
      ?MODULE:generate_admin_cat_rows(NonRoot_Data2, T, Lang, [Z|Html_Acc], Dot_Id)
  end.

%% helper1
%generate_admin_cat_rows_helper1(NonRoot_Data, Root_Data, Lang, Html_Acc, Dot_Id)
generate_admin_cat_rows_helper1(_, [], _, Html_Acc, Dot_Id) ->
  {lists:reverse(Html_Acc), Dot_Id};
%generate_admin_cat_rows_helper1(NonRoot_Data, [{Id,Name,Parent,Status,Ordering}|T], Lang, Html_Acc, Dot_Id)
generate_admin_cat_rows_helper1(NonRoot_Data, [{Id,Name,_,Status,Ordering}|T], Lang, Html_Acc, Dot_Id) ->
  % {Id, Name, Parent, Status, Ordering}
  F1 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> true; _ -> false end end,
  %% filter childs by parent
  ByParent1 = lists:filter(F1,NonRoot_Data),
  
  Id3 = erlang:integer_to_binary(Id),
  case ByParent1 of
    [] ->
      %% no childs
      Z = ?MODULE:generate_admin_cat_rows_helper2(Id3,{Dot_Id,Name},Lang,Status,Ordering),
      ?MODULE:generate_admin_cat_rows_helper1(NonRoot_Data, T, Lang, [Z|Html_Acc], Dot_Id);
    _ ->
      %% childs here
      ByParent2 = lists:keysort(4,ByParent1),
      
      % {Id, Name, Parent, Status, Ordering}
      F2 = fun({_,_,Id2,_,_}) -> case Id2 of Id -> false; _ -> true end end,
      %% filter other -- new non-root data
      NonRoot_Data2 = lists:filter(F2,NonRoot_Data),
      Dot_Id2 = <<"..", Dot_Id/binary>>,
      
      R1 = ?MODULE:generate_admin_cat_rows_helper2(Id3,{Dot_Id,Name},Lang,Status,Ordering),
      
      {R2,Dot_Id3} = ?MODULE:generate_admin_cat_rows_helper1(NonRoot_Data2, ByParent2, Lang, [], Dot_Id2),
      Z = [ R1, R2 ],
      ?MODULE:generate_admin_cat_rows_helper1(NonRoot_Data2, T, Lang, [Z|Html_Acc], Dot_Id3)
  end.


generate_admin_cat_rows_helper2(Id3,Dot_Id_Name,Lang,Status,Ordering) ->
  Part = case Dot_Id_Name of
    {Dot_Id, Name} ->
       [ Dot_Id, <<" ">>, tr_catalog:tr(Lang,Name) ];
    Name ->
      tr_catalog:tr(Lang,Name)
  end,
  Status2 = case Status of
    0 ->
      <<"<option value=\"0\" selected>Hide</option><option value=\"1\">Show</option>">>;
    %1 ->
    _ ->
      <<"<option value=\"0\">Hide</option><option value=\"1\" selected>Show</option>">>
  end,
  [ <<"<p>id : ">>, Id3, <<" | ">>, Part, <<" (<span>">>, Name, <<"</span>) <button onclick=\"upd_category_name(this,">>, Id3, <<");\">Change name</button> <button onclick=\"move_category(this,">>, Id3, <<");\">Move category</button> | <select onchange=\"upd_category_status(this,">>, Id3, <<");\">">>, Status2, <<"</select> | <input class=\"category_order\" type=\"number\" min=\"0\" step=\"1\" value=\"">>, erlang:integer_to_binary(Ordering), <<"\"> <button onclick=\"update_category_order(this,">>, Id3, <<");\">Update ordering</button></p>">> ].


%generate_cat_childsrows(Data,Lang,Acc)
generate_cat_childsrows([],Lang,Acc) ->
  lists:reverse([<<"</p>">>|Acc]);
generate_cat_childsrows(Data,Lang,[]) ->
  SubText = tr:tr(Lang, category, <<"sub_categories">>),
  Z = [ <<"<p><span id=\"no_goods_here\">">>, SubText, <<":</span><br><br>">> ],
  ?MODULE:generate_cat_childsrows(Data,Lang,[Z|[]]);
generate_cat_childsrows([{Id,Name}|T],Lang,Acc) ->
  %Z = [ <<"<p><a href=\"/category/?id=">>, erlang:integer_to_binary(Id), <<"\" target=\"_blank\">">>, Name, <<"</a></p>">> ],
  Name2 = tr_catalog:tr(Lang,Name),
  Z = [ <<"<a href=\"/category/?id=">>, erlang:integer_to_binary(Id), <<"\" target=\"_blank\"><span>">>, Name2, <<"</span></a><br>">> ],
  ?MODULE:generate_cat_childsrows(T,Lang,[Z|Acc]).


generate_admin_addgoodform(Cats_HTML) ->
  [ <<"<label><span>Category:</span><br>">>,
  Cats_HTML,
  <<"</label><br>"
  "<label><span>Title:</span><br>"
  "<input id=\"good_title\" type=\"text\"></label><br>"
  "<label><span>Img Title (only img with created mini-preview):</span><br>"
  "<input id=\"good_img_title\" type=\"text\"></label><br>"
  "<label><span>good&#39;s preview:</span><br>"
  "<textarea id=\"bb_preview_good\">Your good&#39;s preview</textarea></label><br><br>"
  "<label><span>good&#39;s full page describe:</span><br>"
  "<textarea id=\"bb_full_good\">Your good&#39;s full info</textarea></label><br><br>"
  "<label><span>good price</span><br>"
  "<input id=\"good_price\" type=\"text\"></label><br>"
  "<label><span>Available status:</span><br>"
  "<select id=\"good_available_status\">"
  "<option value=\"1\">Available</option>"
  "<option selected value=\"2\">Expecting delivery</option>"
  "<option value=\"3\">Contact the manager</option>"
  "<option value=\"4\">Not available</option>"
  "</select></label><br>"
  "<label><span>Status:</span><br>"
  "<select id=\"good_status\">"
  "<option value=\"1\">Show</option>"
  "<option selected value=\"2\">Hide</option>"
  "</select></label><br>"
  "<button id=\"good_add_new\">Add new good</button><br><br><br>">> ].


%generate_admin_editgoodform({Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}, Cats_HTML, Acc) ->
generate_admin_editgoodform({_, Title, Img_Title, BB_Preview_Text, _, BB_Full_Text, _, Category_Id, Bought_Count, Price, _, _}, Cats_HTML, Acc) ->
  [ <<"<label><span>Category:</span><br>">>,
  Cats_HTML,
  <<"</label><br>"
  "<label><span>Title:</span><br>"
  "<input id=\"good_title\" type=\"text\" value=\"">>, Title, <<"\"></label><br>"
  "<label><span>Img Title (only img with created mini-preview):</span><br>"
  "<input id=\"good_img_title\" type=\"text\" value=\"">>, Img_Title, <<"\"></label><br>"
  "<label><span>good&#39;s preview:</span><br>"
  "<textarea id=\"bb_preview_good\">">>, BB_Preview_Text, <<"</textarea></label><br><br>"
  "<label><span>good&#39;s full page describe:</span><br>"
  "<textarea id=\"bb_full_good\">">>, BB_Full_Text, <<"</textarea></label><br><br>"
  "<label><span>good price</span><br>"
  "<input id=\"good_price\" type=\"text\" value=\"">>, erlang:integer_to_binary(Price), <<"\"></label><br>"
  "<label><span>Available status:</span><br>"
  "<select id=\"good_available_status\">"
  "<option value=\"1\">Available</option>"
  "<option selected value=\"2\">Expecting delivery</option>"
  "<option value=\"3\">Contact the manager</option>"
  "<option value=\"4\">Not available</option>"
  "</select></label><br>"
  "<label><span>Status:</span><br>"
  "<select id=\"good_status\">"
  "<option value=\"1\">Show</option>"
  "<option selected value=\"2\">Hide</option>"
  "</select></label><br>"
  "<button id=\"good_changes_save\">Save changes</button><br><br><br>">> ].


%generate_admin_edithtmlgoodform({Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}, Cats_HTML, Acc) ->
generate_admin_edithtmlgoodform({_, Title, Img_Title, _, Html_Preview_Text, _, Html_Full_Text, Category_Id, Bought_Count, Price, _, _}, Cats_HTML, Acc) ->
  [ <<"<label><span>Category:</span><br>">>,
  Cats_HTML,
  <<"</label><br>"
  "<label><span>Title:</span><br>"
  "<input id=\"good_title\" type=\"text\" value=\"">>, Title, <<"\"></label><br>"
  "<label><span>Img Title (only img with created mini-preview):</span><br>"
  "<input id=\"good_img_title\" type=\"text\" value=\"">>, Img_Title, <<"\"></label><br>"
  "<label><span>good&#39;s preview:</span><br>"
  "<textarea id=\"html_preview_good\">">>, Html_Preview_Text, <<"</textarea></label><br><br>"
  "<label><span>good&#39;s full page describe:</span><br>"
  "<textarea id=\"html_good\">">>, Html_Full_Text, <<"</textarea></label><br><br>"
  "<label><span>good price</span><br>"
  "<input id=\"good_price\" type=\"text\" value=\"">>, erlang:integer_to_binary(Price), <<"\"></label><br>"
  "<label><span>Available status:</span><br>"
  "<select id=\"good_available_status\">"
  "<option value=\"1\">Available</option>"
  "<option selected value=\"2\">Expecting delivery</option>"
  "<option value=\"3\">Contact the manager</option>"
  "<option value=\"4\">Not available</option>"
  "</select></label><br>"
  "<label><span>Status:</span><br>"
  "<select id=\"good_status\">"
  "<option value=\"1\">Show</option>"
  "<option selected value=\"2\">Hide</option>"
  "</select></label><br>"
  "<button id=\"good_changes_save\">Save changes</button><br><br><br>">> ].


generate_admin_loginform() ->
  <<"<input id=\"login\" type=\"text\" placeholder=\"login\"><br>"
  "<input id=\"pass\" type=\"password\" placeholder=\"pass\"><br>"
  "<button id=\"do_login\">Go !</button>">>.


generate_admin_info() ->
  <<"<p>1. Categories -- here you can add and edit categories.</p>"
  "<p>2. Add good -- here you can add new goods.<br>in &quot;img title&quot; write something like &quot;777&quot; -- that you will change after uploading images for this good</p>"
  "<p>3. Images upload -- here you can upload images for goods (attach image for good by good&quot;s id)</p>"
  "<p>4. Images by good&quot;s id -- here you can see already uploaded images, by good&quot;s id, here you can edit order or hide images<br>here you can copy uploaded img url, for make preview and/or put this url in &quot;img title&quot; (2)</p>"
  "<p>5. Make preview for uploaded images -- --||--</p>"
  "<p>6. All goods by pages -- here you can find and edit any good&quot;s info</p>"
  "<p>7. Orders -- here you can see all orders, change their status</p>"/utf8>>.


generate_admin_actionlist() ->
  <<"<p>"
  "<a href=\"/adminka/goods/add/\" target=\"_blank\">Add good</a><br>"
  "<a href=\"/adminka/goods/all/?page=1\" target=\"_blank\">All goods by pages</a><br><br>"
  "<a href=\"/adminka/images/gid_all/\" target=\"_blank\">Images by good&quot;s id</a><br>"
  "<a href=\"/adminka/images/upload/\" target=\"_blank\">Images upload</a><br>"
  "<a href=\"/adminka/images/make_preview/\" target=\"_blank\">Make previews for uploaded images</a><br><br>"
  "<a href=\"/adminka/categories/\" target=\"_blank\">Categories</a><br><br>"
  "<a href=\"/adminka/all_orders/?page=1\" target=\"_blank\">Orders</a><br><br>"
  "<a href=\"/adminka/info/\" target=\"_blank\">Instructions</a><br>"
  "</p>"/utf8>>.


generate_admin_draguploadimg() ->
  <<"<div class=\"container js\" role=\"main\">"
  "<nav role=\"navigation\"><h3>Images Upload</h3></nav>"
  "<label><span>Good&quot;s id for upload images ( 0 for other, non-goods images )</span><br>"
  "<input id=\"box_images_gid\" type=\"number\" min=\"0\" value=\"\"></label>"
  "<div class=\"box\">"
    "<div class=\"box__input\">"
      "<svg class=\"box__icon\" xmlns=\"http://www.w3.org/2000/svg\" width=\"50\" height=\"43\" viewBox=\"0 0 50 43\"><path d=\"M48.4 26.5c-.9 0-1.7.7-1.7 1.7v11.6h-43.3v-11.6c0-.9-.7-1.7-1.7-1.7s-1.7.7-1.7 1.7v13.2c0 .9.7 1.7 1.7 1.7h46.7c.9 0 1.7-.7 1.7-1.7v-13.2c0-1-.7-1.7-1.7-1.7zm-24.5 6.1c.3.3.8.5 1.2.5.4 0 .9-.2 1.2-.5l10-11.6c.7-.7.7-1.7 0-2.4s-1.7-.7-2.4 0l-7.1 8.3v-25.3c0-.9-.7-1.7-1.7-1.7s-1.7.7-1.7 1.7v25.3l-7.1-8.3c-.7-.7-1.7-.7-2.4 0s-.7 1.7 0 2.4l10 11.6z\"/></svg>"
      "<input type=\"file\" name=\"files[]\" id=\"file\" class=\"box__file\" data-multiple-caption=\"{count} files selected\" multiple />"
      "<label for=\"file\"><strong>Choose a file</strong><span class=\"box__dragndrop\"> or drag it here</span>.</label>"
    "</div>"
    "<div class=\"box__uploading\">Uploading&hellip;</div>"
    "<div class=\"box__success\">Done!</div>"
    "<div class=\"box__error\">Error!</div>"
  "</div>"
  "</div>">>.


generate_admin_makepreviewimg() ->
  <<"<div class=\"container\">"
  "<div class=\"content\">"
    "<header class=\"codrops-header\">"
      "<h1>Image Cropping</h1>"
    "</header>"
    "<p class=\"set\">"
      "<label>"
        "<span>Image</span><br>"
        "<input class=\"image_forpreview_1\" type=\"text\" value=\"image.jpg\"><br>"
      "</label>"
      "<label>"
        "<span>Preview width, px</span><br>"
        "<input class=\"preview_width_1\" type=\"number\" min=\"60\" max=\"500\" step=\"10\" value=\"100\"><br>"
      "</label>"
      "<label>"
        "<span>Preview height, px</span><br>"
        "<input class=\"preview_height_1\" type=\"number\" min=\"60\" max=\"300\" step=\"10\" value=\"100\"><br>"
      "</label>"
      "<label>"
        "<span>Preview size</span><br>"
        "<select id=\"preview_1_size\">"
          "<option value=\"1\" selected>mini</option>"
          "<option value=\"2\">micro</option>"
        "</select>"
      "<label>"
    "</p>"
    "<div class=\"component\">"
      "<div class=\"overlay\">"
      "<div class=\"overlay-inner\">"
      "</div>"
      "</div>"
      "<img class=\"resize-image\" src=\"#!\" alt=\"image for resizing\">"
    "</div>"
    "<p><button class=\"btn-crop js-crop\">Create Preview<img class=\"icon-crop\" src=\"/fonts/crop.svg\"></button></p>"
    "<div class=\"a-tip\">"
      "<p><strong>Hint:</strong> hold <span>SHIFT</span> while resizing to keep the original aspect ratio.</p>"
    "</div>"
  "</div>"
  "</div>">>.


generate_admin_gidimg_form() ->
  <<"<label><span>Insert good&apos;s id for look all images for it</span><br>"
  "<input id=\"gidimg\" type=\"number\" min=\"0\" step=\"1\"></label><br>"
  "<button id=\"goto_gidimg\">Go</button>">>.


%generate_admin_gidallimages_rows(Images_Data, Acc)
generate_admin_gidallimages_rows([], Acc) ->
  lists:reverse(Acc);
%generate_admin_gidallimages_rows([{Id, Uid, Path, Name, Status, Order}|T], Acc)
generate_admin_gidallimages_rows([{Id, _, Path, Name, Status, Order}|T], Acc) ->
  if Status =:= 0; Status =:= 1 ->
      % full photo
      
      Z0 = ?MODULE:generate_admin_gidallimages_rows_helper(T, Name, []),
      Z02 = case Z0 of
        [] -> <<"No previews">>;
        _ -> Z0
      end,
      
      SOptions = case Status of
        0 ->
          <<"<option selected value=\"0\">Hide</option><option value=\"1\">Show</option>">>;
        %1 ->
        _ ->
          <<"<option value=\"0\">Hide</option><option selected value=\"1\">Show</option>">>
      end,
      Id2 = erlang:integer_to_binary(Id),
      
      Z = [ <<"<p><img class=\"fullimg\" src=\"/">>, Path, <<"/">>, Name, <<"\"><br><input class=\"imgurl\" type=\"text\" value=\"/">>, Path, <<"/">>, Name, <<"\"><br>Status: <select onchange=\"change_img_status(">>, Id2, <<",this.value);\">">>, SOptions, <<"</select><br>Order: <input type=\"text\" value=\"">>, erlang:integer_to_binary(Order), <<"\"><button onclick=\"change_img_order(">>, Id2, <<",this.previousSibling.value);\">Update order value</button><br>">>, Z02, <<"</p><hr class=\"style16\">">> ],
      ?MODULE:generate_admin_gidallimages_rows(T, [Z|Acc]);
    %Status =:= 2; Status =:= 3 ->
    true ->
      % previews
      Acc
  end.

% helper -- search mini and micro previews by full photo name
%generate_admin_gidallimages_rows_helper(Images_Data, Search_Name, Acc)
generate_admin_gidallimages_rows_helper([], _, Acc) ->
  Acc;
%generate_admin_gidallimages_rows_helper([{Id, Uid, Path, Name, Status, Order}|T], Search_Name, Acc)
generate_admin_gidallimages_rows_helper([{Id, Uid, Path, Name, Status, Order}|T], Search_Name, Acc) ->
  if Name =:= Search_Name ->
      PreviewType = case Status of
        2 ->
          <<"Mini">>;
        %3 ->
        _ ->
          <<"Micro">>
      end,
      
      Z = [ PreviewType, <<"-preview:<br><img src=\"/">>, Path, <<"/">>, Name, <<"\"><br><input class=\"imgurl\" type=\"text\" value=\"/">>, Path, <<"/">>, Name, <<"\"><br>">> ],
      ?MODULE:generate_admin_gidallimages_rows_helper(T, Search_Name, [Z|Acc]);
    true ->
      ?MODULE:generate_admin_gidallimages_rows_helper(T, Search_Name, Acc)
  end.


%generate_goodpage_gidallimages_rows(Images_Data, Images_Data_0, Acc)
generate_goodpage_gidallimages_rows([], _, []) ->
  <<"No images">>;
generate_goodpage_gidallimages_rows([], _, Acc) ->
  lists:reverse(Acc);
%generate_goodpage_gidallimages_rows([{Id, Path, Name}|T], Images_Data_0, Acc) ->
generate_goodpage_gidallimages_rows([{_, Path, Name}|T], Images_Data_0, Acc) ->
  Path_Ends = binary:part(Path,{erlang:byte_size(Path), -5}),
  if Path_Ends =:= <<"/mini">> ->
      ?MODULE:generate_goodpage_gidallimages_rows(T,Images_Data_0,Acc);
    Path_Ends =:= <<"micro">> ->
      ?MODULE:generate_goodpage_gidallimages_rows(T,Images_Data_0,Acc);
    true ->
      Z = ?MODULE:generate_goodpage_gidallimages_rows_helper1(Images_Data_0, Name, Path),
      ?MODULE:generate_goodpage_gidallimages_rows(T,Images_Data_0,[Z|Acc])
  end.

generate_goodpage_gidallimages_rows_helper1(Search_Data, Search_Name, Search_Path) ->
  Search_Path2 = <<Search_Path/binary, "/mini">>,
  R = [ {Path,Name} || {_,Path,Name} <- Search_Data, Name =:= Search_Name, Path =:= Search_Path2 ],
  case R of
    [{Path1,Name1}] ->
      [ <<"<img class=\"jslghtbx-thmb\" src=\"/">>, Path1, <<"/">>, Name1, <<"\" data-jslghtbx=\"/">>, Search_Path, <<"/">>, Search_Name, <<"\" data-jslghtbx-group=\"mygroup1\">">> ];
    %[] ->
    _ ->
      [ <<"<img class=\"jslghtbx-thmb\" src=\"/">>, Search_Path, <<"/">>, Search_Name, <<"\" data-jslghtbx=\"/">>, Search_Path, <<"/">>, Search_Name, <<"\" data-jslghtbx-group=\"mygroup1\">">> ]
  end.


%generate_admin_goods_rows(Goods_Data,Acc)
generate_admin_goods_rows([],Acc) ->
  lists:reverse(Acc);
generate_admin_goods_rows(Goods_Data,[]) ->
  Z = [ <<"<p><label><span>Good&quot;s Id</span><br><input id=\"goto_gid\" type=\"number\" min=\"1\" step=\"1\"></label><br><button onclick=\"goto_goodid(1);\">Edit text &amp; settings</button><br><br><button onclick=\"goto_goodid(2);\">Edit html &amp; settings</button><br><br><button onclick=\"goto_goodid(3);\">Edit images for this good</button></p><hr class=\"style16\">">> ],
  ?MODULE:generate_admin_goods_rows(Goods_Data,[Z|[]]);
generate_admin_goods_rows([{Id, Title, Img_Title, Html_Preview, Price, Available_Status, Status}|T],Acc) ->
  Id2 = erlang:integer_to_binary(Id),
  Img_Title_Preview = case hm:is_substr(erlang:binary_to_list(Img_Title),"/") of
    true ->
      Base = filename:basename(Img_Title),
      Begin = binary:part(Img_Title, 0, erlang:byte_size(Img_Title) - erlang:byte_size(Base)),
      [ <<"<img src=\"">>, Begin, <<"/mini/">>, Base, <<"\">">> ];
    _ ->
      <<"preview image not found">>
  end,
  Available_Status2 = case Available_Status of
    1 -> <<"Available">>;
    2 -> <<"Expecting delivery">>;
    3 -> <<"Contact the manager">>;
    %4 ->
    _ -> <<"Not available">>
  end,
  Status2 = case Status of
    1 -> <<"Show">>;
    %2 ->
    _ -> <<"Hide">>
  end,
  
  Z = [ <<"<p class=\"good">>, Id2, <<"\"><h3>">>, Title, <<"</h3><br>">>, Img_Title_Preview, <<"<br>">>, Html_Preview, <<"<br>Price: ">>, erlang:integer_to_binary(Price), <<" (pennies)<br>Available status: ">>, Available_Status2, <<"<br>Status: ">>, Status2, <<"<br><a href=\"/adminka/goods/edit/?gid=">>, Id2, <<"\" target=\"_blank\"><button>Edit text &amp; settings</button><br><br><a href=\"/adminka/goods/edit_html/?gid=">>, Id2, <<"\" target=\"_blank\"><button>Edit html &amp; settings</button><br><br><a href=\"/adminka/images/gid_all/?gid=">>, Id2, <<"\" target=\"_blank\"><button>Edit images for this good</button><br></a></p><hr class=\"style16\">">> ],
  ?MODULE:generate_admin_goods_rows(T,[Z|Acc]).


%generate_admin_orders_rows(Orders_Data,Acc)
generate_admin_orders_rows([],Acc) ->
  lists:reverse(Acc);
generate_admin_orders_rows(Orders_Data,[]) ->
  Z = [ <<"<p><label><span>Order&quot;s Id</span><br><input id=\"goto_oid\" type=\"number\" min=\"1\" step=\"1\"></label><br><button onclick=\"goto_orderid();\">Go</button></p><hr class=\"style16\">">> ],
  ?MODULE:generate_admin_orders_rows(Orders_Data,[Z|[]]);
generate_admin_orders_rows([{Id, User_Name, User_Phone, User_Email, User_Text, {Goods_Info}, Status, Inserted_At}|T],Acc) ->
  Id2 = erlang:integer_to_binary(Id),
  
  Goods_Info0 = hm:order_goods_info2tuples([],Goods_Info,[]),
  Goods_Info1 = ?MODULE:generate_admin_orders_rows_helper1(Goods_Info0,[],0),
  
  Status2 = case Status of
    1 -> <<"New">>;
    2 -> <<"Ordered ok">>;
    3 -> <<"Deleted">>;
    %4 ->
    _ -> <<"Problem ?">>
  end,
  
  Status3 = case Status of
    1 -> <<"<option value=\"1\" selected>New</option><option value=\"2\">Ordered Ok</option><option value=\"3\">Deleted</option><option value=\"4\">Problem ?</option>">>;
    2 -> <<"<option value=\"1\">New</option><option value=\"2\" selected>Ordered Ok</option><option value=\"3\">Deleted</option><option value=\"4\">Problem ?</option>">>;
    3 -> <<"<option value=\"1\">New</option><option value=\"2\">Ordered Ok</option><option value=\"3\" selected>Deleted</option><option value=\"4\">Problem ?</option>">>;
    %4 ->
    _ -> <<"<option value=\"1\">New</option><option value=\"2\">Ordered Ok</option><option value=\"3\">Deleted</option><option value=\"4\" selected>Problem ?</option>">>
  end,
  
  Inserted_At2 = hm:timestamp2binary(Inserted_At),
  
  Z = [ <<"<p class=\"order\"><h3>Order ">>, Id2, <<"</h3><br>Status: ">>, Status2, <<"<br>DateTime: ">>, Inserted_At2, <<"<br>User Name: ">>, User_Name, <<"<br>User Phone number: ">>, User_Phone, <<"<br>User Email: ">>, User_Email, <<"<br><br>">>, Goods_Info1, <<"<br>User text:<br>">>, User_Text, <<"<br><br>Change status: <select data-id=\"">>, Id2, <<"\" onchange=\"change_order_status(this);\">">>, Status3, <<"</select></p><hr class=\"style16\">">> ],
  ?MODULE:generate_admin_orders_rows(T,[Z|Acc]).

%generate_admin_orders_rows_helper1(Goods_Info,Acc,Acc_Total)
generate_admin_orders_rows_helper1([],Acc,Acc_Total) ->
  [lists:reverse(Acc), <<"<br>Total Price : $">>, hm:balance_int2bin(Acc_Total), <<"<br><br>">>];
generate_admin_orders_rows_helper1(Goods_Info,[],Acc_Total) ->
  Z = <<"<br>Order goods list:<br>">>,
  ?MODULE:generate_admin_orders_rows_helper1(Goods_Info,[Z|[]],Acc_Total);
generate_admin_orders_rows_helper1([{Id,Name,Count,Price}|T],Acc,Acc_Total) ->
  Price2 = erlang:binary_to_integer(Price),
  Price3 = hm:balance_int2bin(Price2),
  Z = [ <<"<a href=\"/goods/?id=">>, Id, <<"\" target=\"_blank\">">>, Name, <<"</a>, Count: ">>, Count, <<", Price: $ ">>, Price3, <<"<br>">> ],
  ?MODULE:generate_admin_orders_rows_helper1(T,[Z|Acc],Acc_Total + (Price2 * erlang:binary_to_integer(Count))).


generate_simple_pagination(Active_Page, Is_Valid_Next) ->
  Begin = case Active_Page of
    1 -> <<"">>;
    _ -> [ <<"<a href=\"?page=">>, erlang:integer_to_binary(Active_Page - 1), <<"\"><button>Previous page</button></a>">> ]
  end,
  End = case Is_Valid_Next of
    true -> [ <<"<a href=\"?page=">>, erlang:integer_to_binary(Active_Page + 1), <<"\"><button>Next page</button></a>">> ];
    _ -> <<"">>
  end,
  [ Begin, End, <<"<hr class=\"style16\">">> ].


generate_sortselect_opts(Lang) ->
  By_Rating = tr:tr(Lang, goods_sort, <<"by_rating">>),
  By_Cheap = tr:tr(Lang, goods_sort, <<"by_cheap">>),
  By_Expensive = tr:tr(Lang, goods_sort, <<"by_expensive">>),
  [ <<"<option value=\"1\" selected>">>, By_Rating, <<"</option>"
  "<option value=\"2\">">>, By_Cheap, <<"</option>"
  "<option value=\"3\">">>, By_Expensive, <<"</option>">> ].


%generate_main_goodscards(PageGoodsData, Lang, Acc)
generate_main_goodscards([],Lang,[]) ->
  No_Data = tr:tr(Lang, main_goods, <<"no_data">>),
  [ <<"<span id=\"no_goods_here\">">>, No_Data, <<" !</span>"/utf8>> ];
generate_main_goodscards([], Lang, Acc) ->
  lists:reverse(Acc);
generate_main_goodscards([{Id, Title, Img_Title, Html_Preview_Text, Bought_Count, Price, Available_Status}|T], Lang, Acc) ->
  %io:format("gid: ~p~n",[Id]),
  [Mini0, Mini1|_] = string:split(Img_Title,"/",trailing),
  Mini_Img = [ Mini0, <<"/mini/">>, Mini1 ],
  
  Rating_Text = tr:tr(Lang, main_goods, <<"rating">>),
  
  Rating = if Bought_Count >= 10, Available_Status =:= 1 ->
      [ <<"<span class=\"rating btn disabled btn-sm\">">>, Rating_Text, <<" ">>, erlang:integer_to_binary(Bought_Count), <<"</span>">> ];
    true ->
      <<"">>
  end,
  Price2 = hm:balance_int2bin(Price),
  
  Delivery_Text = tr:tr(Lang, main_goods, <<"status_delivery">>),
  Contact_Text = tr:tr(Lang, main_goods, <<"status_contact_manager">>),
  NotAvailable_Text = tr:tr(Lang, main_goods, <<"status_not_available">>),
  
  Price_Part = case Available_Status of
    2 -> [ <<"<br><span>">>, Delivery_Text, <<"</span>">> ];
    3 -> [ <<"<br><span>">>, Contact_Text, <<"</span>">> ];
    4 -> [ <<"<br><span>">>, NotAvailable_Text, <<"</span>">> ];
    _ -> <<"">>
  end,
  Id2 = erlang:integer_to_binary(Id),
  
  Details = tr:tr(Lang, main_goods, <<"details">>),
  To_Cart = tr:tr(Lang, main_goods, <<"add_to_cart">>),
  
  All_Price = case wf:config(n2o, currency, "usd") of
    "usd" ->
      [ <<"$ ">>, Price2, Price_Part ];
    %"uah" ->
    _ ->
      [ Price2, Price_Part, <<" грн."/utf8>> ]
  end,
  
  Z = [ <<"<div class=\"card\">"
  "<img class=\"card-img-top jslghtbx-thmb\" src=\"">>, Mini_Img, <<"\" data-jslghtbx=\"">>, Img_Title, <<"\">"
  "<div class=\"card-body\">"
  "<h5 class=\"card-title\"><a href=\"/goods/?id=">>, Id2, <<"\" target=\"_blank\">">>, Title, <<"</a></h5>"
  "<p class=\"card-text\">">>, Html_Preview_Text, <<"</p>"
  "<p class=\"card-text\">">>, Rating, 
  <<"<span class=\"price btn disabled btn-sm\">">>, All_Price, <<"</span>"
  "<a href=\"/goods/?id=">>, Id2, <<"\" target=\"_blank\" class=\"btn btn-outline-primary\">">>, Details, <<"</a>"
  "<a href=\"#!\" class=\"btn btn-success add2cart\" data-id=\"">>, Id2, <<"\" data-price=\"">>, erlang:integer_to_binary(Price), <<"\">">>, To_Cart, <<"</a>"
  "</p>"
  "</div>"
  "</div>">> ],
  ?MODULE:generate_main_goodscards(T, Lang, [Z|Acc]);
generate_main_goodscards(_, _, []) ->
  <<"<span id=\"no_goods_here\">Database error !</span>">>.


prepare_ordermessage_for_tg(Name, Phone, Email, Text, {Goods_Info3}) ->
  
  Goods_Info4 = hm:order_goods_info2tuples([],Goods_Info3,[]),
  Goods_Info5 = ?MODULE:prepare_ordermessage_for_tg_helper1(Goods_Info4,[],0),
  
  Datetime = hm:timestamp2binary(calendar:local_time()),
  
  [ <<"Datetime: ">>, Datetime, "\n", <<"User Name: ">>, Name, "\n", <<"User Phone: ">>, Phone, "\n", <<"User Email: ">>, Email, "\n", <<"User Text: ">>, Text, "\n\n", Goods_Info5 ].

%prepare_ordermessage_for_tg_helper1(Goods_Info,Acc,Acc_Total)
prepare_ordermessage_for_tg_helper1([],Acc,Acc_Total) ->
  Balance = hm:balance_int2bin(Acc_Total),
  All_Balance = case wf:config(n2o, currency, "usd") of
    "usd" ->
      [ <<"$ ">>, Balance ];
    %"uah" ->
    _ ->
      [ Balance, <<" грн."/utf8>> ]
  end,
  [ lists:reverse(Acc), "\n", <<"Total Price : ">>, All_Balance, "\n" ];
prepare_ordermessage_for_tg_helper1(Goods_Info,[],Acc_Total) ->
  Z = [ <<"Order goods list:">>, "\n" ],
  ?MODULE:prepare_ordermessage_for_tg_helper1(Goods_Info,[Z|[]],Acc_Total);
prepare_ordermessage_for_tg_helper1([{Id,Name,Count,Price}|T],Acc,Acc_Total) ->
  Price2 = erlang:binary_to_integer(Price),
  Price3 = hm:balance_int2bin(Price2),
  Price4 = case wf:config(n2o, currency, "usd") of
    "usd" ->
      [ <<"$ ">>, Price3 ];
    %"uah" ->
    _ ->
      [ Price3, <<" грн."/utf8>> ]
  end,
  Z = [ <<"Id: ">>, Id, <<", ">>, Name, <<", Count: ">>, Count, <<", Price (per piece): ">>, Price4, "\n" ],
  ?MODULE:prepare_ordermessage_for_tg_helper1(T,[Z|Acc],Acc_Total + (Price2 * erlang:binary_to_integer(Count))).



