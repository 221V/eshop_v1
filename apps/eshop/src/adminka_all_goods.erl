-module(adminka_all_goods).
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
      
      Adminka_Content = <<"<div id=\"goods_pages\"></div>">>,
      
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
      
      Page = wf:qp(<<"page">>),
      Page_Valid = erlang:is_binary(Page) andalso hm:is_valid_binnumber(Page),
      
      case Page_Valid of
        true ->
          
          Page2 = erlang:binary_to_integer(Page),
          Limit_On_Page = 20,
          [{All_Goods_Count}] = pq:get_goods_count(),
          Page_Valid2 = (All_Goods_Count > (Page2 - 1) * Limit_On_Page),
          
          case Page_Valid2 of
            true ->
              
              Offset = (Page2 - 1) * Limit_On_Page,
              Goods_Data = pq:get_all_goods_adminka_list(Limit_On_Page, Offset),
              Goods_HTML = hg:generate_admin_goods_rows(Goods_Data,[]),
              
              Is_Valid_Next_Page = (All_Goods_Count > (Page2 * Limit_On_Page)),
              Pagination = hg:generate_simple_pagination(Page2, Is_Valid_Next_Page),
              
              wf:wire(wf:f("qi('goods_pages').innerHTML=`~s~s`;", [unicode:characters_to_binary(Goods_HTML,utf8),unicode:characters_to_binary(Pagination,utf8)]));
            _ ->
              % invalid page
              wf:redirect("?page=1")
          end;
        _ ->
          % no page or invalid
          wf:redirect("?page=1")
      end
  end;


event({client,{logout}}) ->
  wf:logout(),
  wf:redirect("/");


event(_) -> [].

