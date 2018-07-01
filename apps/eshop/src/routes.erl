-module(routes).
-author('Maxim Sokhatsky').
-include_lib("n2o/include/wf.hrl").
-export([init/2, finish/2]).

%% U can use default dynamic routes or define custom static as this
%% Just put needed module name to sys.config:
%% {n2o, [{route,routes}]}
%% Also with dynamic routes u must load all modules before starting Cowboy
%% [code:ensure_loaded(M) || M <- [index, login, ... ]]

finish(State, Ctx) -> {ok, State, Ctx}.
init(State, Ctx) ->
    Path = wf:path(Ctx#cx.req),
    wf:info(?MODULE,"Route: ~p~n",[Path]),
    {ok, State, Ctx#cx{path=Path,module=route_prefix(Path)}}.

route_prefix(<<"/ws/",P/binary>>) -> route(P);
route_prefix(<<"/",P/binary>>) -> route(P);
route_prefix(P) -> route(P).

route(<<>>)        -> main;
%route(<<"page/",_/binary>>) -> main;

route(<<"goods/">>) -> good_by_id;
route(<<"category/">>) -> category_by_id;
route(<<"cart/">>) -> cart;

route(<<"adminka/">>) -> adminka;
route(<<"adminka/login/">>) -> adminka_login;
route(<<"adminka/info/">>) -> adminka_info;

route(<<"adminka/images/gid_all/">>) -> adminka_gidall_images;
route(<<"adminka/images/upload/">>) -> adminka_upload_images;
route(<<"adminka/images/make_preview/">>) -> adminka_makepreview_images;

route(<<"adminka/goods/add/">>) -> adminka_add_goods;
route(<<"adminka/goods/edit/">>) -> adminka_edit_goods;
route(<<"adminka/goods/edit_html/">>) -> adminka_edit_html_goods;
route(<<"adminka/goods/all/">>) -> adminka_all_goods;

route(<<"adminka/categories/">>) -> adminka_categories;
route(<<"adminka/all_orders/">>) -> adminka_all_orders;
route(<<"adminka/order_by_id/">>) -> adminka_order_by_id;



%route(<<"test_upload/">>) -> test_upload;

route(_) -> not_found.


