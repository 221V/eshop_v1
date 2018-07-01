-module(pg).
-compile([export_all, nowarn_export_all]).

%% postgresql queries wrapper functions module


transaction(Fun) ->
  case epgsql_pool:transaction(my_main_pool, Fun) of
    {ok, _} ->
      ok;
    Error ->
      io:format("transaction error: ~p~n in tr fun: ~p~n", [Error, Fun]),
      Error
  end.


transaction_q(Worker, Q, A) ->
  epgsql_pool:query(Worker, Q, A).


select(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,_,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


in_up_del(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


returning(Q,A) ->
  case epgsql_pool:query(my_main_pool, Q, A) of
    {ok,1,_,R} ->
      R;
    {error,E} ->
      io:format("~p~n", [E]),
      {error,E}
  end.


