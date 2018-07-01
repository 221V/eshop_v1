-module(tr).
-compile([export_all, nowarn_export_all]).

%translations module

%test lang
tr(<<"en">>, test, <<"lang">>) -> <<"English">>;

tr(<<"ru">>, test, <<"lang">>) -> <<"Русский"/utf8>>;

tr(<<"uk">>, test, <<"lang">>) -> <<"Українська"/utf8>>;


tr(_, _, _) -> <<"">>.

