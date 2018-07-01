-module(eshop).
-behaviour(supervisor).
-behaviour(application).
-export([init/1, start/0, start/2, stop/1, main/1]).


main(A)    -> mad:main(A).
start()    ->
  ssl:start(),
  application:ensure_all_started(eshop),
  start(normal,[]).
start(_,_) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).
stop(_)    -> ok.


init([]) ->
  Params = #{host => wf:config(n2o, pgs_host, "undefined"),
    port => wf:config(n2o, pgs_port, 1),
    username => wf:config(n2o, pgs_user, "undefined"),
    password => wf:config(n2o, pgs_pass, "undefined"),
    database => wf:config(n2o, pgs_db, "undefined")},
  
  case epgsql_pool:start(my_main_pool, 50, 100, Params) of
    {ok, _} ->
      io:format("~p~n",["pg_pool start !!"]),
      ok;
    Z ->
      io:format("Pool start err: ~p~n~p~n", ["err db connect", Z]),
      err
  end,
  
  {ok, {{one_for_one, 5, 10},
    [spec()
  ]}}.

spec()   -> ranch:child_spec(http, 100, ranch_tcp, port(), cowboy_protocol, env()).
env()    -> [ { env, [ { dispatch, points() } ] } ].
%static() ->   { dir, "apps/rupovar/priv/static", mime() }.
%n2o()    ->   { dir, "deps/n2o/priv",           mime() }.
%mime()   -> [ { mimetypes, cow_mimetypes, all   } ].
port()   -> [ { port, wf:config(n2o,port,8000)  } ].
points() -> cowboy_router:compile([{'_', [

%    {"/static/[...]",       n2o_static,  static()},
%    {"/n2o/[...]",          n2o_static,  n2o()},
    {"/multipart/[...]",  n2o_multipart, []},
    {"/ws/[...]",           n2o_stream,  []},
    {'_',                   n2o_cowboy,  []} ]}]).
