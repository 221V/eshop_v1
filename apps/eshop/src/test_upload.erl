-module(test_upload).
-compile([export_all, nowarn_export_all]).
-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/wf.hrl").

main() ->
  %io:format("~tp~n",[wf:render(#span{id=upload})]),
  %io:format("~tp~n",[wf:render(#upload{id=upload})]),
  #dtl{file = "null", app=eshop,bindings=[]}.


event(init) ->
  wf:reg(n2o_session:session_id()),
  io:format(">>> ~p~n",[n2o_session:session_id()]),
  %wf:update(upload,#upload{id=upload});
  %wf:wire(wf:f("ftp_file=undefined;function bind_start_upload(x,meta){x.addEventListener('change',function(e){ftp.meta = utf8_toByteArray(meta);ftp_file=ftp.init(this.files[0]);setTimeout(function(){ftp.start(ftp_file);},3000);});};"
  wf:wire("var cont = document.body;cont.insertAdjacentHTML('afterBegin', '<div id=\"test_upload\"></div>');"
  "var load_js=document.createElement('script');load_js.setAttribute('defer','defer');load_js.setAttribute('src', '/js/n2o/ftp.js');document.body.appendChild(load_js);"),
  
  
  
  wf:wire(wf:f("ftp_file=undefined;function bind_start_upload(x,meta){x.addEventListener('change',function(e){ftp.meta = utf8_toByteArray(meta);ftp.autostart = true;ftp.init(this.files[0]);});};"
  "qi('test_upload').innerHTML='~s';"
  "bind_start_upload(qi('~s'),'~s');",[<<"<label><input id=\"upload_form_1\" type=\"file\"><span>Browse &amp; Upload</span></label>">>,<<"upload_form_1">>,<<"upload_form_1">>]));


%function bind_start_upload(x,meta){
%  x.addEventListener('change',function(e){
%    ftp.meta = utf8_toByteArray(meta);
%    ftp.autostart = true;
%    ftp.init(this.files[0]);
%    //ftp_file=ftp.init(this.files[0]);
%    //ftp.start(ftp_file);
%    //setTimeout(function(){ftp.start(ftp_file);},3000);
%}
%//console.log(this.files[0]); //File { name: "4c529d88a12326.51020076220 A3.jpg", lastModified: 1459898293000, lastModifiedDate: Date 2016-04-05T23:18:13.000Z, webkitRelativePath: "", size: 35434, type: "image/jpeg" }


%-record(ftp, { id, sid, filename, meta, size, offset, block, data, status }).

%event(#ftp{id=Id,sid=Sid,filename=Filename,meta=Meta,size=Size,offset=Offset,block=Block,data=Data,status=Status}) ->
%event(#ftp{status={event,_}}=FTP) ->
%event(#ftp{sid=Sid,filename=Filename,status={event,stop}}=Data) ->

%event(#ftp{sid=Sid,filename=Filename,status={event,Status}}=Data) ->
  %io:format("~p~n",[Filename]),
  %wf:info(?MODULE,"Filename: ~p", [Filename]),
  
  %io:format("~p~n",[Id]), % <<"17431.13">>
  %wf:info(?MODULE,"Id: ~p", [Id]),
  %io:format("~p~n",["777"]),
  %io:format("~p~n",[Sid]), % <<"77f43aeee51eb84879d5735dc21c7ec6">>
  %wf:info(?MODULE,"Sid: ~p", [Sid]),
  %io:format("~p~n",["700"]),
  %io:format("~p~n",[Filename]), % <<"77f43aeee51eb84879d5735dc21c7ec6/3-popup-low.jpg">>
  %wf:info(?MODULE,"Filename: ~p", [Filename]),
  %io:format("~p~n",["7000"]),
  %io:format("~p~n",[Meta]), % <<>>
  %wf:info(?MODULE,"Meta: ~p", [Meta]),
  %io:format("~p~n",["701"]),
  %io:format("~p~n",[Size]), % 26911
  %wf:info(?MODULE,"Size: ~p", [Size]),
  %io:format("~p~n",["702"]),
  %io:format("~p~n",[Offset]), % 0
  %wf:info(?MODULE,"Offset: ~p", [Offset]),
  %io:format("~p~n",["703"]),
  %io:format("~p~n",[Block]), % 262144
  %wf:info(?MODULE,"Block: ~p", [Block]),
  %io:format("~p~n",["704"]),
  %io:format("~p~n",[Data]), % <<>>
  %wf:info(?MODULE,"Data: ~p", [Data]),
  %io:format("~p~n",["705"]),
  %io:format("~p~n",[Status]), % {event,init} | {event,stop}
  %wf:info(?MODULE,"Status: ~p", [Status]),
  %ok;

%tuple(atom('ftp'),
%            bin(item.id),
%            bin(item.sid),
%            bin(item.name),
%            item.meta,
%            number(item.total),
%            number(item.offset),
%            number(item.block || data.byteLength),
%            bin(data),
%            bin(item.status || 'send')
%            )



%event(#ftp{sid=Sid,filename=Filename,status=Status}=Data) ->
%  io:format("test_upload Status: ~p~n",[Status]),
%  ok;


event(#ftp{sid=Sid,filename=Filename,status={event,init}}=Data) ->
  %wf:wire("alert('start send');"),
  io:format("test_upload: ~p~n",["start send"]),
  ok;


event(#ftp{sid=Sid,filename=Filename,status={event,stop}}=Data) ->
  wf:wire("alert('sended');"),
  io:format("test_upload: ~p~n",["sended"]),
  ok;


event(Event) ->
  wf:info(?MODULE,"Event: ~p", [Event]),
  ok.


