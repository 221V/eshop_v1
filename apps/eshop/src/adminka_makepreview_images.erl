-module(adminka_makepreview_images).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").


main() ->
  #dtl{file="null",app=eshop,bindings=[]}.


event(init) ->
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      wf:redirect("/adminka/login/");
    _ ->
      %N2O_S = n2o_session:session_id(),
      %Rand_S = erlang:integer_to_binary(random:uniform(7777777)),
      %wf:reg(<<N2O_S/binary, Rand_S/binary>>),
      wf:reg(n2o_session:session_id()),
      
      wf:wire(wf:f("document.title='~s';", [<<"Admin panel"/utf8>>])),
      wf:wire("var load_css1=document.createElement('link');load_css1.setAttribute('rel', 'stylesheet');load_css1.setAttribute('type', 'text/css');load_css1.setAttribute('href', '/css/normalize.css');document.body.appendChild(load_css1);"),
      wf:wire("var load_css2=document.createElement('link');load_css2.setAttribute('rel', 'stylesheet');load_css2.setAttribute('type', 'text/css');load_css2.setAttribute('href', '/css/resize_crop.css');document.body.appendChild(load_css2);"),
      wf:wire("var load_css3=document.createElement('link');load_css3.setAttribute('rel', 'stylesheet');load_css3.setAttribute('type', 'text/css');load_css3.setAttribute('href', '/css/resize_crop_component.css');document.body.appendChild(load_css3);"),
      
      
      InfoHTML = hg:generate_admin_makepreviewimg(),
      
      wf:wire(wf:f("var div = document.createElement('div');div.innerHTML='~s';"
                   "document.body.appendChild(div);", [unicode:characters_to_binary(InfoHTML,utf8)])),
      wf:wire("var load_js=document.createElement('script');load_js.setAttribute('defer','defer');load_js.setAttribute('src', '/js/n2o/ftp.js');document.body.appendChild(load_js);"),
      wf:wire("var load_js2=document.createElement('script');load_js2.setAttribute('defer','defer');load_js2.setAttribute('src', '/js/jquery-2.1.1.min.js');document.body.appendChild(load_js2);"),
      wf:wire("var load_js3=document.createElement('script');load_js3.setAttribute('defer','defer');load_js3.setAttribute('src', '/js/resize_crop_component.js');document.body.appendChild(load_js3);")
  end;


event(#ftp{id=Link,sid=Sid,filename=FileName,size=Size,status={event,init}}=Data) ->
  %io:format("test_upload: ~p~n",["start send"]),
  %io:format("file Size: ~p~n",[Size]), % file Size: 6327569
  
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      n2o_async:stop(file, Link);
    _ ->

      %[Path, Name|_] = string:split(FileName, <<"/">>, trailing),
      %[_,_,_,_,GId,Type|_] = string:split(Path, <<"/">>, all),
      
      %Status = case Type of
      %  <<"mini">> -> 2;
      %  %<<"micro">> -> 3
      %  _ -> 3
      %end,
      
      %UId = wf:session(uid),
      %GId2 = erlang:binary_to_integer(GId),
      
      %case pq:get_mini_image(GId2, Path, Name, Status) of
      %  [{_}] -> file:delete("/var/www/eshop/uploads/" ++ erlang:binary_to_list(FileName));
      %  [] -> ok;
      %  _ -> err
      %end,
      
      %io:format("~p~n", [file:get_cwd()]),% file:delete("/var/www/eshop/uploads/" ++ "imgs/2018/06/08/1/mini/di_Bartini0.jpg")
      
      Maxsize = 2097152, % 2Mb in b = 2*1024*1024 = 2097152
      if Size > Maxsize ->
          
          % n2o_async:stop(file,Name), де кожен процес файлу за Name   = { Sid, Filename, Hash }, зареестрований
          % Name={Sid,filename:basename(FileName)},
          
          wf:wire(wf:f("alert('~s size > 2Mb !');",[filename:basename(FileName)])),
          %wf:wire("window.is_sending_file=false;"),
          
          %PName = {Sid, filename:basename(FileName)},
          %n2o_async:stop(file, PName);
          n2o_async:stop(file, Link);
        true ->
          %io:format("~p~n", ["222"]),
          ok
      end
  end;


event(#ftp{sid=Sid,meta=Meta,filename=Filename,status={event,stop}}=Data) ->
  %io:format("~p~n", ["sended"]),
  %io:format("~p~n", [Meta]), % "1"
  %io:format("~p~n", [Filename]), % <<"imgs/2018/06/08/1/mini/4.jpg">>

  [Path, Name|_] = string:split(Filename, <<"/">>, trailing),
  [_,_,_,_,GId,Type|_] = string:split(Path, <<"/">>, all),
  
  Status = case Type of
    <<"mini">> -> 2;
    %<<"micro">> -> 3
    _ -> 3
  end,
  
  UId = wf:session(uid),
  GId2 = erlang:binary_to_integer(GId),
  
  case pq:get_mini_image(GId2, Path, Name, Status) of
    [{_}] -> ok;
    [] -> pq:add_mini_image(UId, GId2, Path, Name, Status);
    _ -> err
  end,
  %io:format("~p~n", ["555"]),
  %wf:wire("window.is_sending_file=false;"),
  wf:wire("alert('saved !');");


event(_) -> [].

