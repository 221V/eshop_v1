-module(adminka_order_by_id).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  %#dtl{file="null",app=eshop,bindings=[]}.
  
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect({http,"/adminka/login/"});
    _ ->
      Order_Id = wf:qp(<<"id">>),
      Order_Id_Valid = erlang:is_binary(Order_Id) andalso hm:is_valid_binnumber(Order_Id),
      
      case Order_Id_Valid of
        true ->
          
          Order_Data = pq:get_order_by_id(erlang:binary_to_integer(Order_Id)),
          
          case Order_Data of
            %[{Id, User_Name, User_Phone, User_Email, User_Text, Goods_Info, Status, Inserted_At}] ->
            [{_,_,_,_,_,_,_,_}] ->
              
              % found and show
              
              Order_HTML = hg:generate_admin_orders_rows(Order_Data,[]),
              
              Title = <<"Adminka | Eshop">>,
              Adminka_Main = <<"Adminka">>,
              Adminka_Logout = <<"Logout">>,
              
              Adminka_Content = [ <<"<div id=\"orders_pages\">">>, Order_HTML, <<"</div>">> ],
              
              #dtl{file="adminka",app=eshop,bindings=[ {pagetitle, Title},
              {adminka_main, Adminka_Main},
              {adminka_logout, Adminka_Logout},
              {adminka_content, unicode:characters_to_binary(Adminka_Content,utf8)} ]};
            [] ->
              % not found
              Title = <<"Adminka | Eshop">>,
              Adminka_Main = <<"Adminka">>,
              Adminka_Logout = <<"Logout">>,
              
              Adminka_Content = <<"<div id=\"orders_pages\">Not found</div>">>,
              
              #dtl{file="adminka",app=eshop,bindings=[ {pagetitle, Title},
              {adminka_main, Adminka_Main},
              {adminka_logout, Adminka_Logout},
              {adminka_content, Adminka_Content} ]};
            _ ->
              % err
              Title = <<"Adminka | Eshop">>,
              Adminka_Main = <<"Adminka">>,
              Adminka_Logout = <<"Logout">>,
              
              Adminka_Content = <<"<div id=\"orders_pages\">Database error</div>">>,
              
              #dtl{file="adminka",app=eshop,bindings=[ {pagetitle, Title},
              {adminka_main, Adminka_Main},
              {adminka_logout, Adminka_Logout},
              {adminka_content, Adminka_Content} ]}
          end;
        _ ->
          
          Title = <<"Adminka | Eshop">>,
          Adminka_Main = <<"Adminka">>,
          Adminka_Logout = <<"Logout">>,
          
          Adminka_Content = <<"<div id=\"orders_pages\">Invalid id</div>">>,
          
          #dtl{file="adminka",app=eshop,bindings=[ {pagetitle, Title},
          {adminka_main, Adminka_Main},
          {adminka_logout, Adminka_Logout},
          {adminka_content, Adminka_Content} ]}
      end
  end.


event(init) ->
  ok;


event({client,{update_status,Id,Val}})
when erlang:is_integer(Id), Id > 0, erlang:is_integer(Val), Val >= 1, Val =< 4 ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      pq:upd_order_status_by_id(Id, Val),
      wf:wire("window.updstatus_wait=false;")
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

