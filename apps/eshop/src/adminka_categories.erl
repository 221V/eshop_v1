-module(adminka_categories).
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
      
      Title = <<"Adminka | Eshop">>,
      Adminka_Main = <<"Adminka">>,
      Adminka_Logout = <<"Logout">>,
      
      Adminka_Content = <<"<div id=\"all_categories\"></div>">>,
      
      #dtl{file="adminka",app=eshop,bindings=[ {pagetitle, Title},
      {adminka_main, Adminka_Main},
      {adminka_logout, Adminka_Logout},
      {adminka_content, Adminka_Content} ]}
  end.


event(init) ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      
      Cats_Data = pq:get_categories(),
      Cats_HTML = hg:generate_admin_cat_rows(Cats_Data, [], [], <<"">>),
      
      wf:wire(wf:f("qi('all_categories').innerHTML='~s';", [unicode:characters_to_binary(Cats_HTML,utf8)]))
  end;


event({client,{update_order,Id,Val}})
when erlang:is_integer(Id), Id > 0, erlang:is_integer(Val), Val >= 0  ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      case pq:get_category_by_id(Id) of
        [{_,_,_}] ->
          % category exists
          
          pq:upd_category_order_by_id(Id, Val),
          
          Cats_Data = pq:get_categories(),
          Cats_HTML = hg:generate_admin_cat_rows(Cats_Data, [], [], <<"">>),
          
          wf:wire(wf:f("qi('all_categories').innerHTML='~s';", [unicode:characters_to_binary(Cats_HTML,utf8)])),
          wf:wire("window.updorder_wait=false;");
        [] ->
          % category not exists
          wf:wire("alert('invalid data !');window.updorder_wait=false;");
        _ ->
          wf:wire("alert('db err !');window.updorder_wait=false;")
      end
  end;


event({client,{update_name,Id,Val}})
when erlang:is_integer(Id), Id > 0, erlang:is_binary(Val), Val =/= <<"">>  ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      case pq:get_category_by_id(Id) of
        [{_,_,_}] ->
          % category exists
          
          Val2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Val))),
          pq:upd_category_name_by_id(Id, Val2),
          
          Cats_Data = pq:get_categories(),
          Cats_HTML = hg:generate_admin_cat_rows(Cats_Data, [], [], <<"">>),
          
          wf:wire(wf:f("qi('all_categories').innerHTML='~s';", [unicode:characters_to_binary(Cats_HTML,utf8)])),
          wf:wire("window.updname_wait=false;");
        [] ->
          % category not exists
          wf:wire("alert('invalid data !');window.updname_wait=false;");
        _ ->
          wf:wire("alert('db err !');window.updname_wait=false;")
      end
  end;


event({client,{new_category,Val}})
when erlang:is_binary(Val), Val =/= <<"">> ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      Val2 = hm:htmlspecialchars(erlang:binary_to_list(hm:trim(Val))),
      case pq:get_category_by_name(Val2) of
        [{_}] ->
          % category already exists
          wf:wire("alert('this category already exists !');window.newname_wait=false;");
        [] ->
          % not exists, we can create
          
          pq:add_category(Val2, 0),
          
          Cats_Data = pq:get_categories(),
          Cats_HTML = hg:generate_admin_cat_rows(Cats_Data, [], [], <<"">>),
          
          wf:wire(wf:f("qi('all_categories').innerHTML='~s';", [unicode:characters_to_binary(Cats_HTML,utf8)])),
          wf:wire("window.newname_wait=false;");
        _ ->
          wf:wire("alert('database error !');window.newname_wait=false;")
      end
  end;


event({client,{move_category,Id,Parent_Id}})
when erlang:is_integer(Id), Id > 0, erlang:is_integer(Parent_Id), Parent_Id > 0  ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      case pq:get_category_by_id(Id) of
        [{_,_,_}] ->
          % category for move exists
          case pq:get_category_by_id(Parent_Id) of
            [{_,_,_}] ->
              % parent category exists
              
              pq:upd_category_parent_by_ids(Id, Parent_Id),
              
              Cats_Data = pq:get_categories(),
              Cats_HTML = hg:generate_admin_cat_rows(Cats_Data, [], [], <<"">>),
              
              wf:wire(wf:f("qi('all_categories').innerHTML='~s';", [unicode:characters_to_binary(Cats_HTML,utf8)])),
              wf:wire("window.movecat_wait=false;");
            [] ->
              % category not exists
              wf:wire("alert('invalid data !');window.movecat_wait=false;");
            _ ->
              wf:wire("alert('db err !');window.movecat_wait=false;")
          end;
        [] ->
          % category not exists
          wf:wire("alert('invalid data !');window.movecat_wait=false;");
        _ ->
          wf:wire("alert('db err !');window.movecat_wait=false;")
      end
  end;


event({client,{change_status,Id,Val}})
when erlang:is_integer(Id), Id > 0, erlang:is_integer(Val) ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      if Val =:= 0; Val =:= 1 ->
          case pq:get_category_by_id(Id) of
            [{_,_,_}] ->
              % category exists
              pq:upd_category_status_by_id(Id, Val),
              wf:wire("window.catstatus_wait=false;");
            [] ->
              % category not exists
              wf:wire("alert('invalid data !');window.catstatus_wait=false;");
            _ ->
              wf:wire("alert('db err !');window.catstatus_wait=false;")
          end;
        true ->
          err
      end
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

