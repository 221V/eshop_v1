-module(adminka_login).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  #dtl{file="null",app=eshop,bindings=[]}.


event(init) ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      
      wf:wire("document.title='Please LogIn';"),
      wf:wire("var load_js=document.createElement('script');load_js.setAttribute('defer','defer');load_js.setAttribute('src', '/js/admin.js');document.body.appendChild(load_js);"),
      LoginFormHTML = hg:generate_admin_loginform(),
      
      wf:wire(wf:f("var div = document.createElement('div');div.innerHTML='~s';"
                   "document.body.appendChild(div);", [unicode:characters_to_binary(LoginFormHTML,utf8)])),
      wf:wire("setTimeout(function(){ do_login_bind(); }, 1000);");
    _ ->
      wf:redirect("/adminka/")
  end;


event({client,{login, Login, Pass}}) ->
  Valid = ((erlang:is_list(Login) and (Login =/= "")) and hm:is_valid_email(hm:trim_l(Login))) and (erlang:is_list(Pass) and (Pass =/= "")),
  
  case Valid of
    true ->
      
      Email2 = hm:trim_l(Login),
      case pq:get_user_login(Email2) of
        [{_, _, 3}] -> wf:wire("window.login_wait=false;alert('account deleted !');");
        [{_, _, 2}] -> wf:wire("window.login_wait=false;alert('account banned !');");
        [{Uid, Password, 1}] ->
          
          Pass2 = hm:trim_l(Pass),
          case Password =:= erlang:list_to_binary(hm:hash_pass(Pass2)) of
            true ->
              
              wf:session(uid, Uid),
              wf:user(Email2),
              wf:redirect("/adminka/");
            _ -> wf:wire("window.login_wait=false;alert('invalid login and/or password !');")
          end;
        [] -> wf:wire("window.login_wait=false;alert('invalid login and/or password !');");
        _ -> wf:wire("window.login_wait=false;alert('db error !');")
      end;
    _ ->
      wf:wire("window.login_wait=false;alert('invalid login and/or password !');")
end;


event(_) -> [].

