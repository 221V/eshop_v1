-module(adminka_add_goods).
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
      
      Adminka_Content = <<"<div id=\"add_new\"></div>">>,
      
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
      
      wf:wire("var load_js2=document.createElement('script');load_js2.setAttribute('defer','defer');load_js2.setAttribute('src', '/js/sceditor.min.js');document.body.appendChild(load_js2);"),
      wf:wire("var load_js3=document.createElement('script');load_js3.setAttribute('defer','defer');load_js3.setAttribute('src', '/js/monocons.js');document.body.appendChild(load_js3);"),
      wf:wire("var load_js4=document.createElement('script');load_js4.setAttribute('defer','defer');load_js4.setAttribute('src', '/js/bbcode.js');document.body.appendChild(load_js4);"),
      
      wf:wire("var load_css1=document.createElement('link');load_css1.setAttribute('rel', 'stylesheet');load_css1.setAttribute('type', 'text/css');load_css1.setAttribute('href', '/css/sceditor-default.min.css');document.body.appendChild(load_css1);"),
      wf:wire("var load_css2=document.createElement('link');load_css2.setAttribute('rel', 'stylesheet');load_css2.setAttribute('type', 'text/css');load_css2.setAttribute('href', '/css/mybbcodes.css');document.body.appendChild(load_css2);"),
      
      Cats_Data = pq:get_categories(),
      Cats_HTML = hg:generate_admin_cat_list(Cats_Data, [], [], <<"">>),
      
      Form_HTML = hg:generate_admin_addgoodform(Cats_HTML),
      
      wf:wire(wf:f("qi('add_new').innerHTML='~s';", [unicode:characters_to_binary(Form_HTML,utf8)])),
      
      wf:wire("setTimeout(function(){ textareas_init();do_addgood_bind(); }, 1000);")
  end;


event({client,{new_good, Cat_Id, Title, Title_Img, Preview_BB, Full_BB, Price, Available_Status, Status}}) when erlang:is_integer(Cat_Id), Cat_Id > 0, erlang:is_list(Title), Title =/= "", erlang:is_list(Title_Img), Title_Img =/= "", erlang:is_list(Preview_BB), Preview_BB =/= "", erlang:is_list(Full_BB), Full_BB =/= "", erlang:is_integer(Price), Price > 0, erlang:is_integer(Available_Status), Available_Status > 0, Available_Status < 5, erlang:is_integer(Status), Status > 0, Status < 3 ->
  
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      
      case pq:get_category_by_id(Cat_Id) of
        [{_Name,_Parent,_Ordering}] ->
          % ok, category found
          
          
          Preview_BB1 = hm:htmlspecialchars(Preview_BB),
          {ok, Preview_BB2, _} = bbcodeslex:string(unicode:characters_to_list(Preview_BB1,utf8)),
          Preview_HTML = hm:leex_parser(Preview_BB2,[]),
          Full_BB1 = hm:htmlspecialchars(Full_BB),
          {ok, Full_BB2, _} = bbcodeslex:string(unicode:characters_to_list(Full_BB1,utf8)),
          Full_HTML = hm:leex_parser(Full_BB2,[]),
          
          UId = wf:session(uid),
          Title2 = hm:htmlspecialchars(hm:trim_l(Title)),
          Title_Img2 = hm:htmlspecialchars(hm:trim_l(Title_Img)),
          
          pq:add_new_good(UId, Title2, Title_Img2, Preview_BB1, unicode:characters_to_binary(Preview_HTML,utf8), Full_BB1, unicode:characters_to_binary(Full_HTML,utf8), Cat_Id, Price, Available_Status, Status),
          
          wf:wire("alert('new good added successfully !');location.reload();");
        [] ->
          % err, category not found
          wf:wire("alert('invalid category !');");
        _ ->
          % db err
          wf:wire("alert('database eror !');")
      end
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

