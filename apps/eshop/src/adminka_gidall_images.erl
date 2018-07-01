-module(adminka_gidall_images).
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
      
      Adminka_Content = <<"<div id=\"gidall_images\"></div>">>,
      
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
      
      GId = wf:qp(<<"gid">>),
      GId_Valid = erlang:is_binary(GId) andalso hm:is_valid_binnumber(GId),
      case GId_Valid of
        true ->
          
          GId2 = erlang:binary_to_integer(GId),
          
          Images_Data = pq:get_all_images_by_gid(GId2),
          
          case Images_Data of
            [] ->
              % no data
              Images_HTML = <<"No data">>,
              wf:wire(wf:f("qi('gidall_images').innerHTML='~s';", [unicode:characters_to_binary(Images_HTML,utf8)]));
            [_H|_] ->
              % data exists
              Images_HTML = hg:generate_admin_gidallimages_rows(Images_Data, []),
              wf:wire(wf:f("qi('gidall_images').innerHTML='~s';", [unicode:characters_to_binary(Images_HTML,utf8)]));
            _ ->
              % database error
              Images_HTML = <<"Database error">>,
              wf:wire(wf:f("qi('gidall_images').innerHTML='~s';", [unicode:characters_to_binary(Images_HTML,utf8)]))
          end;
        _ ->
          % invalid good's id
          % so we show form
          Images_HTML = hg:generate_admin_gidimg_form(),
          wf:wire(wf:f("qi('gidall_images').innerHTML='~s';"
            "bind_show_gidimg();", [unicode:characters_to_binary(Images_HTML,utf8)]))
      end
  end;


event({client,{update_status, Id, Val}}) when erlang:is_integer(Id), erlang:is_integer(Val) ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      case pq:get_image_status(Id) of
        [{Status}|_] ->
          if Status =:= 0, Val =:= 1 ->
              pq:upd_image_status(Id,Val);
            Status =:= 1, Val =:= 0 ->
              pq:upd_image_status(Id,Val);
            true ->
              ok
          end,
          wf:wire("window.updstatus_wait=false;");
        _ ->
          wf:wire("alert('error 7251 !');")
      end
  end;


event({client,{update_order, Id, Val}}) when erlang:is_integer(Id), erlang:is_integer(Val), Val > 0 ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      case pq:get_image_order(Id) of
        [{_Order}|_] ->
          pq:upd_image_order(Id,Val),
          wf:wire("window.updorder_wait=false;");
        _ ->
          wf:wire("alert('error 7250 !');")
      end
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

