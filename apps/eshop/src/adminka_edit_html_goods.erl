-module(adminka_edit_html_goods).
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
      
      Adminka_Content = <<"<div id=\"good_edit\"></div>">>,
      
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
          
          case pq:get_goods_adminka_by_id(GId2) of
            %[{Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}|_] ->
            [{_, _, _, _, _, _, _, Category_Id, _, _, Available_Status, Status} = Good_Data|_] ->
              
              Cats_Data = pq:get_categories(),
              Cats_HTML = hg:generate_admin_cat_list(Cats_Data, [], [], <<"">>),
              Good_HTML = hg:generate_admin_edithtmlgoodform(Good_Data, Cats_HTML, []),
              
              wf:wire("var load_css2=document.createElement('link');load_css2.setAttribute('rel', 'stylesheet');load_css2.setAttribute('type', 'text/css');load_css2.setAttribute('href', '/css/mybbcodes.css');document.body.appendChild(load_css2);"),
              
              wf:wire(wf:f("qi('good_edit').innerHTML=`~s`;", [unicode:characters_to_binary(Good_HTML,utf8)])),
              wf:wire(wf:f("found_and_select(qi('cat_id'), ~s);"
              "found_and_select(qi('good_available_status'), ~s);"
              "found_and_select(qi('good_status'), ~s);",[erlang:integer_to_binary(Category_Id), erlang:integer_to_binary(Available_Status), erlang:integer_to_binary(Status)])),
              
              wf:wire("setTimeout(function(){ do_edithtml_good_bind(); }, 1000);");
            [] ->
              wf:wire("qi('good_edit').innerHTML='invalid good&apos;s id!';");
            _ ->
              wf:wire("qi('good_edit').innerHTML='database error';")
          end;
        _ ->
          wf:wire("qi('good_edit').innerHTML='invalid good&apos;s id!';")
      end
  end;


event({client,{update_html_good, Cat_Id, Title, Title_Img, Preview_HTML, Full_HTML, Price, Available_Status, Status}}) when erlang:is_integer(Cat_Id), Cat_Id > 0, erlang:is_list(Title), Title =/= "", erlang:is_list(Title_Img), Title_Img =/= "", erlang:is_list(Preview_HTML), Preview_HTML =/= "", erlang:is_list(Full_HTML), Full_HTML =/= "", erlang:is_integer(Price), Price > 0, erlang:is_integer(Available_Status), Available_Status > 0, Available_Status < 5, erlang:is_integer(Status), Status > 0, Status < 3 ->
  
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
        
        case pq:get_goods_adminka_by_id(GId2) of
          %[{Id, Title, Img_Title, BB_Preview_Text, Html_Preview_Text, BB_Full_Text, Html_Full_Text, Category_Id, Bought_Count, Price, Available_Status, Status}|_] ->
          [{_, _, _, _, _, _, _, _, _, _, _, _}|_] ->
            % good is found
            
            case pq:get_category_by_id(Cat_Id) of
              [{_Name,_Parent,_Ordering}] ->
                % ok, category found
                
                %UId = wf:session(uid),
                Title2 = hm:htmlspecialchars(hm:trim_l(Title)),
                Title_Img2 = hm:htmlspecialchars(hm:trim_l(Title_Img)),
                
                pq:update_good_html_by_id(GId2, Title2, Title_Img2, hm:trim_l(Preview_HTML), hm:trim_l(Full_HTML), Cat_Id, Price, Available_Status, Status),
                
                wf:wire("alert('updated successfully !');window.send_wait = false;");
              [] ->
                % err, category not found
                wf:wire("alert('invalid category !');");
              _ ->
                % db err
                wf:wire("alert('database eror !');")
            end;
          [] ->
            % good not found
            wf:wire("qi('good_edit').innerHTML='invalid good&apos;s id!';");
          _ ->
            wf:wire("alert('database error 756332 !');")
        end;
      _ ->
        wf:wire("qi('good_edit').innerHTML='invalid good&apos;s id!';")
    end
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

