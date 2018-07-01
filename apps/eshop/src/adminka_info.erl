-module(adminka_info).
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
      
      Adminka_Content = <<"<div id=\"all_info\"></div>">>,
      
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
      
      InfoHTML = hg:generate_admin_info(),
      
      wf:wire(wf:f("qi('all_info').innerHTML='~s';", [unicode:characters_to_binary(InfoHTML,utf8)]))
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

