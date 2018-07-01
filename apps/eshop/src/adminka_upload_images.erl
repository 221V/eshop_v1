-module(adminka_upload_images).
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
      wf:reg(n2o_session:session_id()),
      
      wf:wire(wf:f("document.title='~s';", [<<"Admin panel"/utf8>>])),
      wf:wire("var load_css1=document.createElement('link');load_css1.setAttribute('rel', 'stylesheet');load_css1.setAttribute('type', 'text/css');load_css1.setAttribute('href', '/css/imgupload.css');document.body.appendChild(load_css1);"),
      wf:wire("var load_css2=document.createElement('link');load_css2.setAttribute('rel', 'stylesheet');load_css2.setAttribute('type', 'text/css');load_css2.setAttribute('href', '//fonts.googleapis.com/css?family=Roboto:300,300italic,400');document.body.appendChild(load_css2);"),
      
      InfoHTML = hg:generate_admin_draguploadimg(),
      
      wf:wire(wf:f("var div = document.createElement('div');div.innerHTML='~s';"
                   "document.body.appendChild(div);", [unicode:characters_to_binary(InfoHTML,utf8)])),
      wf:wire("var load_js=document.createElement('script');load_js.setAttribute('defer','defer');load_js.setAttribute('src', '/js/n2o/ftp.js');document.body.appendChild(load_js);"),
      wf:wire("var load_js2=document.createElement('script');load_js2.setAttribute('defer','defer');load_js2.setAttribute('src', '/js/imgupload.js');document.body.appendChild(load_js2);")
  end;


event(#ftp{id=Link,sid=Sid,filename=FileName,size=Size,status={event,init}}=Data) ->
  %io:format("test_upload: ~p~n",["start send"]),
  %io:format("file Size: ~p~n",[Size]), % file Size: 6327569
  
  UserEmail = wf:user(),
  case UserEmail of
    undefined ->
      n2o_async:stop(file, Link);
    _ ->
      
      Maxsize = 2097152, % 2Mb in b = 2*1024*1024 = 2097152
      if Size > Maxsize ->
          
          % n2o_async:stop(file,Name), де кожен процес файлу за Name   = { Sid, Filename, Hash }, зареестрований
          % Name={Sid,filename:basename(FileName)},
          
          wf:wire(wf:f("alert('~s size > 2Mb !');",[filename:basename(FileName)])),
          wf:wire("window.is_sending_file=false;"),
          
          %PName = {Sid, filename:basename(FileName)},
          %n2o_async:stop(file, PName);
          n2o_async:stop(file, Link);
        true ->
          ok
      end
  end;


event(#ftp{sid=Sid,meta=Meta,filename=Filename,status={event,stop}}=Data) ->
  %io:format("~p~n", ["sended"]),
  %io:format("~p~n", [Meta]), % "1"
  %io:format("~p~n", [Filename]), % <<"imgs/2018/06/08/1/777.jpg">>
  %wf:wire(wf:f("alert('~s sended');", [Filename])),
  
  [Path, Name|_] = string:split(Filename, <<"/">>, trailing),
  [_,_,_,_,GId|_] = string:split(Path, <<"/">>, all),
  
  UId = wf:session(uid),
  
  pq:add_full_image(UId, erlang:binary_to_integer(GId), Path, Name),
  
  wf:wire("window.is_sending_file=false;"),
  ok;


event(_) -> [].


